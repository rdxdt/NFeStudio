unit uemissaonfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, ACBrNFe, ACBrNFe.Classes;

type

  TResultadoEmissao = record
    Autorizada: Boolean;
    cStat: integer;
    xMotivo: string;
    Chave: string;
    Protocolo: string;
  end;

  { TEmissaoNFe }

  TEmissaoNFe = class(TComponent)
  private
    FACBrNFe: TACBrNFe;
    procedure SetACBrNFe(AValue: TACBrNFe);
    function GetNFe: TNFe;
    procedure VerificarACBrNFe;
    procedure ValidarIdentificacao(Erros: TStrings);
    procedure ValidarEmitente(Erros: TStrings);
    procedure ValidarDestinatario(Erros: TStrings);
    procedure ValidarItens(Erros, Avisos: TStrings);
    procedure ValidarPagamentos(Erros: TStrings);
    procedure ValidarRegrasACBr(Erros: TStrings);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure PrepararEnvio; virtual;
    procedure EnviarSEFAZ; virtual;
  public
    procedure NovaNota(Ini: TCustomIniFile);
    procedure PreencherEmitente(Ini: TCustomIniFile);
    procedure AplicarRegrasModelo;
    procedure AplicarRegrasFinalidade;
    procedure DefinirDestinoOperacao;
    function NovoItem: TDetCollectionItem;
    procedure RenumerarItens;
    procedure CalcularItem(Det: TDetCollectionItem);
    procedure CalcularTotais;
    procedure CarregarXML(const Arquivo: string);
    procedure SalvarXML(const Arquivo: string);
    function Validar(Erros, Avisos: TStrings): Boolean;
    function Emitir: TResultadoEmissao;
    property NFe: TNFe read GetNFe;
  published
    property ACBrNFe: TACBrNFe read FACBrNFe write SetACBrNFe;
  end;

const
  MODELO_NFE = 55;
  MODELO_NFCE = 65;

function EhCFOPDevolucao(const CFOP: string): Boolean;
function EhSimplesNacional(NFe: TNFe): Boolean;

implementation

uses
  StrUtils, Math, ACBrUtil.Strings, ACBrUtil.Base, ACBrUtil.Math, ACBrDFeUtil,
  pcnConversao, pcnConversaoNFe, ACBrDFe.Conversao, ACBrNFeNotasFiscais;

const
  // mesmas seção/chaves gravadas pelo frmConfig
  SECAO_EMITENTE = 'Emitente';
  VERSAO_PROCESSO = 'NFeStudio';
  CODIGO_PAIS_BRASIL = 1058;
  NOME_PAIS_BRASIL = 'BRASIL';
  SEM_GTIN = 'SEM GTIN';
  MAX_ITENS = 990;
  // CFOP de devolução de mercadoria; usada só para aviso, pois a lista varia com a legislação
  CFOPS_DEVOLUCAO: array[0..85] of string = (
    '1201', '1202', '1203', '1204', '1208', '1209', '1410', '1411', '1503', '1504',
    '1505', '1506', '1553', '1660', '1661', '1662', '1918', '1919',
    '2201', '2202', '2203', '2204', '2208', '2209', '2410', '2411', '2503', '2504',
    '2505', '2506', '2553', '2660', '2661', '2662', '2918', '2919',
    '3201', '3202', '3211', '3503', '3553',
    '5201', '5202', '5208', '5209', '5210', '5410', '5411', '5412', '5413', '5503',
    '5553', '5555', '5556', '5660', '5661', '5662', '5918', '5919', '5921',
    '6201', '6202', '6208', '6209', '6210', '6410', '6411', '6412', '6413', '6503',
    '6553', '6555', '6556', '6660', '6661', '6662', '6918', '6919', '6921',
    '7201', '7202', '7210', '7211', '7553', '7556', '7930');

  MSG_SEM_ACBRNFE = 'Componente ACBrNFe não atribuído à emissão';
  MSG_SEM_NOTA = 'Nenhuma nota carregada';
  MSG_XML_SEM_NFE = 'O arquivo %s não contém NF-e/NFC-e';
  MSG_ERRO_GRAVACAO = 'Não foi possível gravar %s';

function EhCFOPDevolucao(const CFOP: string): Boolean;
begin
  Result := AnsiIndexStr(CFOP, CFOPS_DEVOLUCAO) >= 0;
end;

function EhSimplesNacional(NFe: TNFe): Boolean;
begin
  Result := NFe.Emit.CRT in [crtSimplesNacional, crtSimplesExcessoReceita, crtMEI];
end;

function Arredondar(Valor: Double): Currency;
begin
  Result := RoundABNT(Valor, -2);
end;

procedure AdicionarErro(Lista: TStrings; const Grupo, Mensagem: string);
begin
  Lista.Add(Grupo + ': ' + Mensagem);
end;

{ TEmissaoNFe }

procedure TEmissaoNFe.SetACBrNFe(AValue: TACBrNFe);
begin
  if FACBrNFe = AValue then
    Exit;
  if Assigned(FACBrNFe) then
    FACBrNFe.RemoveFreeNotification(Self);
  FACBrNFe := AValue;
  if Assigned(FACBrNFe) then
    FACBrNFe.FreeNotification(Self);
end;

procedure TEmissaoNFe.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FACBrNFe) then
    FACBrNFe := nil;
end;

procedure TEmissaoNFe.VerificarACBrNFe;
begin
  if not Assigned(FACBrNFe) then
    raise Exception.Create(MSG_SEM_ACBRNFE);
end;

function TEmissaoNFe.GetNFe: TNFe;
begin
  VerificarACBrNFe;
  if FACBrNFe.NotasFiscais.Count = 0 then
    raise Exception.Create(MSG_SEM_NOTA);
  Result := FACBrNFe.NotasFiscais[0].NFe;
end;

procedure TEmissaoNFe.NovaNota(Ini: TCustomIniFile);
var
  Nota: TNFe;
begin
  VerificarACBrNFe;
  FACBrNFe.NotasFiscais.Clear;
  Nota := FACBrNFe.NotasFiscais.Add.NFe;
  Nota.infNFe.Versao := VersaoDFToDbl(FACBrNFe.Configuracoes.Geral.VersaoDF);
  if FACBrNFe.Configuracoes.Geral.ModeloDF = moNFCe then
    Nota.Ide.modelo := MODELO_NFCE
  else
    Nota.Ide.modelo := MODELO_NFE;
  Nota.Ide.serie := 1;
  Nota.Ide.nNF := 1;
  // zero: o ACBr gera o código numérico aleatório ao montar a chave
  Nota.Ide.cNF := 0;
  Nota.Ide.natOp := 'VENDA';
  Nota.Ide.dEmi := Now;
  Nota.Ide.tpNF := tnSaida;
  Nota.Ide.idDest := doInterna;
  Nota.Ide.tpImp := tiRetrato;
  Nota.Ide.tpEmis := FACBrNFe.Configuracoes.Geral.FormaEmissao;
  Nota.Ide.tpAmb := FACBrNFe.Configuracoes.WebServices.Ambiente;
  Nota.Ide.finNFe := fnNormal;
  Nota.Ide.indFinal := cfNao;
  Nota.Ide.indPres := pcPresencial;
  Nota.Ide.indIntermed := iiSemOperacao;
  Nota.Ide.procEmi := peAplicativoContribuinte;
  Nota.Ide.verProc := VERSAO_PROCESSO;
  Nota.Dest.indIEDest := inNaoContribuinte;
  Nota.Dest.EnderDest.cPais := CODIGO_PAIS_BRASIL;
  Nota.Dest.EnderDest.xPais := NOME_PAIS_BRASIL;
  Nota.Transp.modFrete := mfSemFrete;
  PreencherEmitente(Ini);
  AplicarRegrasModelo;
end;

procedure TEmissaoNFe.PreencherEmitente(Ini: TCustomIniFile);
var
  Emit: TEmit;
  CRT: TpcnCRT;
  Ok: Boolean;
begin
  Emit := NFe.Emit;
  Emit.CNPJCPF := Ini.ReadString(SECAO_EMITENTE, 'CNPJCPF', '');
  Emit.IE := Ini.ReadString(SECAO_EMITENTE, 'IE', '');
  Emit.xNome := Ini.ReadString(SECAO_EMITENTE, 'RazaoSocial', '');
  Emit.xFant := Ini.ReadString(SECAO_EMITENTE, 'Fantasia', '');
  CRT := StrToCRT(Ok, Ini.ReadString(SECAO_EMITENTE, 'CRT', ''));
  if Ok then
    Emit.CRT := CRT;
  Emit.EnderEmit.fone := Ini.ReadString(SECAO_EMITENTE, 'Fone', '');
  Emit.EnderEmit.CEP := StrToIntDef(Ini.ReadString(SECAO_EMITENTE, 'CEP', ''), 0);
  Emit.EnderEmit.xLgr := Ini.ReadString(SECAO_EMITENTE, 'Logradouro', '');
  Emit.EnderEmit.nro := Ini.ReadString(SECAO_EMITENTE, 'Numero', '');
  Emit.EnderEmit.xCpl := Ini.ReadString(SECAO_EMITENTE, 'Complemento', '');
  Emit.EnderEmit.xBairro := Ini.ReadString(SECAO_EMITENTE, 'Bairro', '');
  Emit.EnderEmit.cMun := Ini.ReadInteger(SECAO_EMITENTE, 'CodMunicipio', 0);
  Emit.EnderEmit.xMun := Ini.ReadString(SECAO_EMITENTE, 'Municipio', '');
  Emit.EnderEmit.UF := Ini.ReadString(SECAO_EMITENTE, 'UF', '');
  Emit.EnderEmit.cPais := CODIGO_PAIS_BRASIL;
  Emit.EnderEmit.xPais := NOME_PAIS_BRASIL;
  // UF e município do fato gerador seguem o emitente
  if Emit.EnderEmit.UF <> '' then
    NFe.Ide.cUF := UFparaCodigoUF(Emit.EnderEmit.UF);
  NFe.Ide.cMunFG := Emit.EnderEmit.cMun;
end;

procedure TEmissaoNFe.AplicarRegrasModelo;
var
  Nota: TNFe;
begin
  Nota := NFe;
  if Nota.Ide.modelo = MODELO_NFCE then
  begin
    // NFC-e: saída interna, presencial ou entrega a domicílio, para consumidor final
    // (rejeições 706, 707, 715, 716, 717, 709, 708, 729, 730 e 760)
    Nota.Ide.tpNF := tnSaida;
    Nota.Ide.idDest := doInterna;
    Nota.Ide.indFinal := cfConsumidorFinal;
    Nota.Ide.finNFe := fnNormal;
    Nota.Ide.dSaiEnt := 0;
    if not (Nota.Ide.indPres in [pcPresencial, pcEntregaDomicilio]) then
      Nota.Ide.indPres := pcPresencial;
    if not (Nota.Ide.tpImp in [tiNFCe, tiMsgEletronica]) then
      Nota.Ide.tpImp := tiNFCe;
    // SCAN e SVC não autorizam NFC-e (782/783); a contingência da NFC-e é a off-line
    if not (Nota.Ide.tpEmis in [teNormal, teOffLine]) then
      Nota.Ide.tpEmis := teNormal;
    Nota.Ide.NFref.Clear;
    Nota.Dest.indIEDest := inNaoContribuinte;
    Nota.Dest.IE := '';
    Nota.Dest.ISUF := '';
    Nota.Emit.IEST := '';
    if Nota.Ide.indPres = pcPresencial then
      Nota.Transp.modFrete := mfSemFrete;
    Nota.Cobr.Fat.nFat := '';
    Nota.Cobr.Fat.vOrig := 0;
    Nota.Cobr.Fat.vDesc := 0;
    Nota.Cobr.Fat.vLiq := 0;
    Nota.Cobr.Dup.Clear;
  end
  else
  begin
    if Nota.Ide.tpImp in [tiNFCe, tiMsgEletronica] then
      Nota.Ide.tpImp := tiRetrato;
    // entrega a domicílio (794) e contingência off-line (711) são exclusivas da NFC-e
    if Nota.Ide.indPres = pcEntregaDomicilio then
      Nota.Ide.indPres := pcPresencial;
    if Nota.Ide.tpEmis = teOffLine then
      Nota.Ide.tpEmis := teNormal;
  end;
end;

procedure TEmissaoNFe.AplicarRegrasFinalidade;
var
  Nota: TNFe;
  I: integer;
begin
  Nota := NFe;
  // ajuste e devolução não têm pagamento: único pagamento "90 - Sem pagamento" (MOC YA02-20, rejeição 871)
  if Nota.Ide.finNFe in [fnAjuste, fnDevolucao] then
  begin
    Nota.pag.Clear;
    Nota.pag.New.tPag := fpSemPagamento;
    Nota.pag.vTroco := 0;
  end;
  if Nota.Ide.finNFe <> fnDebito then
    Nota.Ide.tpNFDebito := tdNenhum;
  if Nota.Ide.finNFe <> fnCredito then
    Nota.Ide.tpNFCredito := tcNenhum;
  if Nota.Ide.finNFe <> fnDevolucao then
    for I := 0 to Nota.Det.Count - 1 do
    begin
      Nota.Det[I].pDevol := 0;
      Nota.Det[I].vIPIDevol := 0;
    end;
end;

procedure TEmissaoNFe.DefinirDestinoOperacao;
var
  Nota: TNFe;
  UFDest: string;
begin
  Nota := NFe;
  if Nota.Ide.modelo = MODELO_NFCE then
    Exit;
  UFDest := UpperCase(Nota.Dest.EnderDest.UF);
  if UFDest = '' then
    Exit;
  if UFDest = 'EX' then
    Nota.Ide.idDest := doExterior
  else if (UFDest = UpperCase(Nota.Emit.EnderEmit.UF)) or (Nota.Ide.indPres = pcPresencial) then
    // venda presencial a não residente é operação interna (rejeição 773)
    Nota.Ide.idDest := doInterna
  else
    Nota.Ide.idDest := doInterestadual;
end;

function TEmissaoNFe.NovoItem: TDetCollectionItem;
var
  Nota: TNFe;
  Anterior: TDetCollectionItem;
begin
  Nota := NFe;
  Anterior := nil;
  if Nota.Det.Count > 0 then
    Anterior := Nota.Det[Nota.Det.Count - 1];
  Result := Nota.Det.New;
  Result.Prod.nItem := Nota.Det.Count;
  Result.Prod.cEAN := SEM_GTIN;
  Result.Prod.cEANTrib := SEM_GTIN;
  Result.Prod.IndTot := itSomaTotalNFe;
  // repete CFOP e tributação do item anterior, o caso mais comum numa mesma nota
  if Assigned(Anterior) then
  begin
    Result.Prod.CFOP := Anterior.Prod.CFOP;
    Result.Imposto.ICMS.orig := Anterior.Imposto.ICMS.orig;
    Result.Imposto.ICMS.CST := Anterior.Imposto.ICMS.CST;
    Result.Imposto.ICMS.CSOSN := Anterior.Imposto.ICMS.CSOSN;
    Result.Imposto.ICMS.modBC := Anterior.Imposto.ICMS.modBC;
    Result.Imposto.ICMS.pICMS := Anterior.Imposto.ICMS.pICMS;
    Result.Imposto.PIS.CST := Anterior.Imposto.PIS.CST;
    Result.Imposto.PIS.pPIS := Anterior.Imposto.PIS.pPIS;
    Result.Imposto.COFINS.CST := Anterior.Imposto.COFINS.CST;
    Result.Imposto.COFINS.pCOFINS := Anterior.Imposto.COFINS.pCOFINS;
    Exit;
  end;
  if Nota.Ide.tpNF = tnEntrada then
    Result.Prod.CFOP := '1102'
  else if Nota.Ide.idDest = doInterestadual then
    Result.Prod.CFOP := '6102'
  else if Nota.Ide.idDest = doExterior then
    Result.Prod.CFOP := '7102'
  else
    Result.Prod.CFOP := '5102';
  Result.Imposto.ICMS.orig := oeNacional;
  Result.Imposto.ICMS.modBC := dbiValorOperacao;
  if EhSimplesNacional(Nota) then
  begin
    Result.Imposto.ICMS.CSOSN := csosn102;
    Result.Imposto.PIS.CST := pis49;
    Result.Imposto.COFINS.CST := cof49;
  end
  else
  begin
    Result.Imposto.ICMS.CST := cst00;
    Result.Imposto.PIS.CST := pis01;
    Result.Imposto.COFINS.CST := cof01;
  end;
end;

procedure TEmissaoNFe.RenumerarItens;
var
  I: integer;
begin
  for I := 0 to NFe.Det.Count - 1 do
    NFe.Det[I].Prod.nItem := I + 1;
end;

procedure TEmissaoNFe.CalcularItem(Det: TDetCollectionItem);
var
  Prod: TProd;
  ICMS: TICMS;
  IBSCBS: TgIBSCBS;
  Base, BaseST: Double;
  TributaICMS, TributaST: Boolean;
begin
  Prod := Det.Prod;
  ICMS := Det.Imposto.ICMS;
  // nota complementar de valor pode ter quantidade zero: mantém o vProd informado
  if (Prod.qCom > 0) and (Prod.vUnCom > 0) then
    Prod.vProd := Arredondar(Prod.qCom * Prod.vUnCom);
  // sem unidade tributável distinta, os dados tributáveis repetem os comerciais (rejeição 630)
  if (Prod.uTrib = '') or (Prod.uTrib = Prod.uCom) then
  begin
    Prod.uTrib := Prod.uCom;
    Prod.qTrib := Prod.qCom;
    Prod.vUnTrib := Prod.vUnCom;
  end;

  Base := Prod.vProd - Prod.vDesc + Prod.vFrete + Prod.vSeg + Prod.vOutro;

  if EhSimplesNacional(NFe) then
  begin
    TributaICMS := ICMS.CSOSN = csosn900;
    TributaST := ICMS.CSOSN in [csosn201, csosn202, csosn203, csosn900];
    if ICMS.CSOSN in [csosn101, csosn201, csosn900] then
      ICMS.vCredICMSSN := Arredondar(Base * ICMS.pCredSN / 100);
  end
  else
  begin
    TributaICMS := ICMS.CST in [cst00, cst10, cst20, cst51, cst70, cst90];
    TributaST := ICMS.CST in [cst10, cst30, cst70, cst90];
  end;

  if TributaICMS and (ICMS.pICMS > 0) then
  begin
    ICMS.vBC := Arredondar(Base * (1 - ICMS.pRedBC / 100));
    ICMS.vICMS := Arredondar(ICMS.vBC * ICMS.pICMS / 100);
    if ICMS.pFCP > 0 then
    begin
      ICMS.vBCFCP := ICMS.vBC;
      ICMS.vFCP := Arredondar(ICMS.vBC * ICMS.pFCP / 100);
    end;
  end;

  if Det.Imposto.IPI.pIPI > 0 then
  begin
    Det.Imposto.IPI.vBC := Arredondar(Prod.vProd + Prod.vFrete + Prod.vSeg + Prod.vOutro);
    Det.Imposto.IPI.vIPI := Arredondar(Det.Imposto.IPI.vBC * Det.Imposto.IPI.pIPI / 100);
  end;

  if TributaST and (ICMS.pICMSST > 0) then
  begin
    // o IPI integra a base do ICMS-ST
    BaseST := (Base + Det.Imposto.IPI.vIPI) * (1 + ICMS.pMVAST / 100) * (1 - ICMS.pRedBCST / 100);
    ICMS.vBCST := Arredondar(BaseST);
    ICMS.vICMSST := Max(Double(0), Arredondar(ICMS.vBCST * ICMS.pICMSST / 100) - ICMS.vICMS);
  end;

  if Det.Imposto.PIS.pPIS > 0 then
  begin
    Det.Imposto.PIS.vBC := Arredondar(Base);
    Det.Imposto.PIS.vPIS := Arredondar(Base * Det.Imposto.PIS.pPIS / 100);
  end;
  if Det.Imposto.COFINS.pCOFINS > 0 then
  begin
    Det.Imposto.COFINS.vBC := Arredondar(Base);
    Det.Imposto.COFINS.vCOFINS := Arredondar(Base * Det.Imposto.COFINS.pCOFINS / 100);
  end;

  IBSCBS := Det.Imposto.IBSCBS.gIBSCBS;
  if (IBSCBS.gIBSUF.pIBSUF > 0) or (IBSCBS.gIBSMun.pIBSMun > 0) or (IBSCBS.gCBS.pCBS > 0) then
  begin
    IBSCBS.vBC := Arredondar(Base);
    IBSCBS.gIBSUF.vIBSUF := Arredondar(IBSCBS.vBC * IBSCBS.gIBSUF.pIBSUF / 100);
    IBSCBS.gIBSMun.vIBSMun := Arredondar(IBSCBS.vBC * IBSCBS.gIBSMun.pIBSMun / 100);
    IBSCBS.gCBS.vCBS := Arredondar(IBSCBS.vBC * IBSCBS.gCBS.pCBS / 100);
  end;
end;

procedure TEmissaoNFe.CalcularTotais;
var
  Nota: TNFe;
  Tot: TICMSTot;
  Det: TDetCollectionItem;
  I: integer;
  vBCIBSCBS, vIBSUF, vIBSMun, vCBS, TotalPago: Double;
begin
  Nota := NFe;
  Tot := Nota.Total.ICMSTot;
  Tot.vBC := 0;
  Tot.vICMS := 0;
  Tot.vICMSDeson := 0;
  Tot.vFCP := 0;
  Tot.vBCST := 0;
  Tot.vST := 0;
  Tot.vFCPST := 0;
  Tot.vFCPSTRet := 0;
  Tot.vProd := 0;
  Tot.vFrete := 0;
  Tot.vSeg := 0;
  Tot.vDesc := 0;
  Tot.vII := 0;
  Tot.vIPI := 0;
  Tot.vIPIDevol := 0;
  Tot.vPIS := 0;
  Tot.vCOFINS := 0;
  Tot.vOutro := 0;
  Tot.vTotTrib := 0;
  vBCIBSCBS := 0;
  vIBSUF := 0;
  vIBSMun := 0;
  vCBS := 0;
  // mesmas regras de soma do ValidarRegrasdeNegocios do ACBr (rejeições 531 a 610)
  for I := 0 to Nota.Det.Count - 1 do
  begin
    Det := Nota.Det[I];
    Tot.vFrete := Tot.vFrete + Det.Prod.vFrete;
    Tot.vSeg := Tot.vSeg + Det.Prod.vSeg;
    Tot.vOutro := Tot.vOutro + Det.Prod.vOutro;
    Tot.vDesc := Tot.vDesc + Det.Prod.vDesc;
    Tot.vII := Tot.vII + Det.Imposto.II.vII;
    Tot.vIPI := Tot.vIPI + Det.Imposto.IPI.vIPI;
    Tot.vIPIDevol := Tot.vIPIDevol + Det.vIPIDevol;
    Tot.vICMSDeson := Tot.vICMSDeson + Det.Imposto.ICMS.vICMSDeson;
    Tot.vPIS := Tot.vPIS + Det.Imposto.PIS.vPIS;
    Tot.vCOFINS := Tot.vCOFINS + Det.Imposto.COFINS.vCOFINS;
    Tot.vTotTrib := Tot.vTotTrib + Det.Imposto.vTotTrib;
    vBCIBSCBS := vBCIBSCBS + Det.Imposto.IBSCBS.gIBSCBS.vBC;
    vIBSUF := vIBSUF + Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.vIBSUF;
    vIBSMun := vIBSMun + Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.vIBSMun;
    vCBS := vCBS + Det.Imposto.IBSCBS.gIBSCBS.gCBS.vCBS;
    if Det.Prod.IndTot = itSomaTotalNFe then
    begin
      Tot.vBC := Tot.vBC + Det.Imposto.ICMS.vBC;
      Tot.vICMS := Tot.vICMS + Det.Imposto.ICMS.vICMS;
      Tot.vBCST := Tot.vBCST + Det.Imposto.ICMS.vBCST;
      Tot.vST := Tot.vST + Det.Imposto.ICMS.vICMSST;
      Tot.vFCP := Tot.vFCP + Det.Imposto.ICMS.vFCP;
      Tot.vFCPST := Tot.vFCPST + Det.Imposto.ICMS.vFCPST;
      Tot.vFCPSTRet := Tot.vFCPSTRet + Det.Imposto.ICMS.vFCPSTRet;
      Tot.vProd := Tot.vProd + Det.Prod.vProd;
    end;
  end;
  Tot.vNF := (Tot.vProd + Tot.vST + Tot.vFrete + Tot.vSeg + Tot.vOutro + Tot.vII + Tot.vIPI +
    Tot.vFCPST + Tot.vIPIDevol) - (Tot.vDesc + Tot.vICMSDeson);

  Nota.Total.IBSCBSTot.vBCIBSCBS := vBCIBSCBS;
  Nota.Total.IBSCBSTot.gIBS.gIBSUFTot.vIBSUF := vIBSUF;
  Nota.Total.IBSCBSTot.gIBS.gIBSMunTot.vIBSMun := vIBSMun;
  Nota.Total.IBSCBSTot.gIBS.vIBS := vIBSUF + vIBSMun;
  Nota.Total.IBSCBSTot.gCBS.vCBS := vCBS;

  // troco: o que exceder o total da nota
  if Nota.Ide.finNFe = fnNormal then
  begin
    Nota.pag.vTroco := 0;
    TotalPago := 0;
    for I := 0 to Nota.pag.Count - 1 do
      TotalPago := TotalPago + Nota.pag[I].vPag;
    if TotalPago > Tot.vNF then
      Nota.pag.vTroco := TotalPago - Tot.vNF;
  end;
end;

procedure TEmissaoNFe.CarregarXML(const Arquivo: string);
begin
  VerificarACBrNFe;
  FACBrNFe.NotasFiscais.Clear;
  FACBrNFe.NotasFiscais.LoadFromFile(Arquivo);
  if FACBrNFe.NotasFiscais.Count = 0 then
    raise Exception.CreateFmt(MSG_XML_SEM_NFE, [Arquivo]);
  // um lote (enviNFe) é editado nota a nota: mantém somente a primeira
  while FACBrNFe.NotasFiscais.Count > 1 do
    FACBrNFe.NotasFiscais.Delete(1);
end;

procedure TEmissaoNFe.SalvarXML(const Arquivo: string);
begin
  if NFe = nil then
    Exit;
  // XML de rascunho: gerado sem assinatura, pode ser salvo mesmo com pendências de validação
  FACBrNFe.NotasFiscais[0].GerarXML;
  if not FACBrNFe.NotasFiscais[0].GravarXML(Arquivo) then
    raise Exception.CreateFmt(MSG_ERRO_GRAVACAO, [Arquivo]);
end;

procedure TEmissaoNFe.ValidarIdentificacao(Erros: TStrings);
const
  GRUPO = 'Identificação';
var
  Ide: TIde;
begin
  Ide := NFe.Ide;
  if Trim(Ide.natOp) = '' then
    AdicionarErro(Erros, GRUPO, 'natureza da operação não informada');
  if (Ide.nNF < 1) or (Ide.nNF > 999999999) then
    AdicionarErro(Erros, GRUPO, 'número da nota deve estar entre 1 e 999.999.999');
  if (Ide.serie < 0) or (Ide.serie > 999) then
    AdicionarErro(Erros, GRUPO, 'série deve estar entre 0 e 999');
  if Ide.dEmi = 0 then
    AdicionarErro(Erros, GRUPO, 'data de emissão não informada');
  if (Ide.dSaiEnt > 0) and (Ide.dSaiEnt < Ide.dEmi) then
    AdicionarErro(Erros, GRUPO, 'data de saída/entrada anterior à emissão');
  if Ide.tpEmis <> teNormal then
  begin
    if Ide.dhCont = 0 then
      AdicionarErro(Erros, GRUPO, 'contingência sem data/hora de entrada');
    if (Length(Trim(Ide.xJust)) < 15) or (Length(Trim(Ide.xJust)) > 256) then
      AdicionarErro(Erros, GRUPO, 'justificativa da contingência deve ter de 15 a 256 caracteres');
  end;
  // intermediador só existe em operações não presenciais (indPres 2, 3, 4 e 9)
  if Ide.indPres in [pcInternet, pcTeleatendimento, pcEntregaDomicilio, pcOutros] then
  begin
    if Ide.indIntermed = iiSemOperacao then
      AdicionarErro(Erros, GRUPO, 'indicador de intermediador obrigatório para operação não presencial');
  end
  else if Ide.indIntermed <> iiSemOperacao then
    AdicionarErro(Erros, GRUPO, 'indicador de intermediador só pode ser informado em operação não presencial');
  if Ide.indIntermed = iiOperacaoComIntermediador then
  begin
    if not ValidarCNPJouCPF(NFe.infIntermed.CNPJ) then
      AdicionarErro(Erros, GRUPO, 'CNPJ do intermediador inválido');
    if Trim(NFe.infIntermed.idCadIntTran) = '' then
      AdicionarErro(Erros, GRUPO, 'identificador do intermediador não informado');
  end;
  if (Ide.finNFe = fnDebito) and (Ide.tpNFDebito = tdNenhum) then
    AdicionarErro(Erros, GRUPO, 'nota de débito sem o tipo de débito');
  if (Ide.finNFe = fnCredito) and (Ide.tpNFCredito = tcNenhum) then
    AdicionarErro(Erros, GRUPO, 'nota de crédito sem o tipo de crédito');
  if (Ide.finNFe in [fnCredito, fnDebito]) and (Ide.modelo = MODELO_NFCE) then
    AdicionarErro(Erros, GRUPO, 'notas de crédito e débito são exclusivas da NF-e');
end;

procedure TEmissaoNFe.ValidarEmitente(Erros: TStrings);
const
  GRUPO = 'Emitente';
var
  Emit: TEmit;
begin
  Emit := NFe.Emit;
  if not ValidarCNPJouCPF(Emit.CNPJCPF) then
    AdicionarErro(Erros, GRUPO, 'CNPJ/CPF inválido');
  if Trim(Emit.xNome) = '' then
    AdicionarErro(Erros, GRUPO, 'razão social não informada');
  if Trim(Emit.IE) = '' then
    AdicionarErro(Erros, GRUPO, 'inscrição estadual não informada')
  else if not ValidarIE(Emit.IE, Emit.EnderEmit.UF) then
    AdicionarErro(Erros, GRUPO, 'inscrição estadual inválida para a UF');
  if (Trim(Emit.EnderEmit.xLgr) = '') or (Trim(Emit.EnderEmit.nro) = '') or
     (Trim(Emit.EnderEmit.xBairro) = '') or (Trim(Emit.EnderEmit.xMun) = '') then
    AdicionarErro(Erros, GRUPO, 'endereço incompleto (logradouro, número, bairro e município)');
  if Length(IntToStr(Emit.EnderEmit.cMun)) <> 7 then
    AdicionarErro(Erros, GRUPO, 'código do município deve ter 7 dígitos');
  if UFparaCodigoUF(Emit.EnderEmit.UF) <= 0 then
    AdicionarErro(Erros, GRUPO, 'UF inválida');
end;

procedure TEmissaoNFe.ValidarDestinatario(Erros: TStrings);
const
  GRUPO = 'Destinatário';
var
  Nota: TNFe;
  Dest: TDest;
begin
  Nota := NFe;
  Dest := Nota.Dest;
  if (Dest.CNPJCPF = '') and (Dest.idEstrangeiro = '') then
  begin
    // NFC-e aceita consumidor não identificado, exceto na entrega a domicílio (787, validada pelo ACBr)
    if Nota.Ide.modelo = MODELO_NFE then
      AdicionarErro(Erros, GRUPO, 'informe o CNPJ/CPF ou o identificador de estrangeiro');
    Exit;
  end;
  if (Dest.CNPJCPF <> '') and not ValidarCNPJouCPF(Dest.CNPJCPF) then
    AdicionarErro(Erros, GRUPO, 'CNPJ/CPF inválido');
  if Trim(Dest.xNome) = '' then
    AdicionarErro(Erros, GRUPO, 'nome não informado');
  case Dest.indIEDest of
    inContribuinte:
      if Trim(Dest.IE) = '' then
        AdicionarErro(Erros, GRUPO, 'contribuinte do ICMS sem inscrição estadual')
      else if not ValidarIE(Dest.IE, Dest.EnderDest.UF) then
        AdicionarErro(Erros, GRUPO, 'inscrição estadual inválida para a UF');
    inIsento:
      if Trim(Dest.IE) <> '' then
        AdicionarErro(Erros, GRUPO, 'contribuinte isento não deve informar inscrição estadual');
    inNaoContribuinte:
      // rejeição 696: operação com não contribuinte é sempre com consumidor final
      if Nota.Ide.indFinal <> cfConsumidorFinal then
        AdicionarErro(Erros, GRUPO, 'operação com não contribuinte deve indicar consumidor final');
  end;
end;

procedure TEmissaoNFe.ValidarItens(Erros, Avisos: TStrings);
var
  Nota: TNFe;
  Det: TDetCollectionItem;
  I: integer;
  Grupo, PrimeiroDigito, DigitosValidos: string;
begin
  Nota := NFe;
  if Nota.Det.Count = 0 then
    AdicionarErro(Erros, 'Itens', 'a nota deve ter ao menos um item');
  if Nota.Det.Count > MAX_ITENS then
    AdicionarErro(Erros, 'Itens', Format('a nota pode ter no máximo %d itens', [MAX_ITENS]));

  // primeiro dígito do CFOP: 1/2/3 entrada, 5/6/7 saída; 1/5 interna, 2/6 interestadual, 3/7 exterior
  if Nota.Ide.tpNF = tnEntrada then
    DigitosValidos := '123'
  else
    DigitosValidos := '567';
  case Nota.Ide.idDest of
    doInterna: DigitosValidos := DigitosValidos[1];
    doInterestadual: DigitosValidos := DigitosValidos[2];
    doExterior: DigitosValidos := DigitosValidos[3];
  end;

  for I := 0 to Nota.Det.Count - 1 do
  begin
    Det := Nota.Det[I];
    Grupo := Format('Item %d', [I + 1]);
    if Trim(Det.Prod.cProd) = '' then
      AdicionarErro(Erros, Grupo, 'código do produto não informado');
    if Trim(Det.Prod.xProd) = '' then
      AdicionarErro(Erros, Grupo, 'descrição não informada');
    if Trim(Det.Prod.uCom) = '' then
      AdicionarErro(Erros, Grupo, 'unidade comercial não informada');
    if not (Length(Det.Prod.NCM) in [2, 8]) or (OnlyNumber(Det.Prod.NCM) <> Det.Prod.NCM) then
      AdicionarErro(Erros, Grupo, 'NCM deve ter 8 dígitos (ou 00 para serviço)');
    if (Length(Det.Prod.CFOP) <> 4) or (OnlyNumber(Det.Prod.CFOP) <> Det.Prod.CFOP) then
      AdicionarErro(Erros, Grupo, 'CFOP deve ter 4 dígitos')
    else
    begin
      PrimeiroDigito := Det.Prod.CFOP[1];
      if Pos(PrimeiroDigito, DigitosValidos) = 0 then
        AdicionarErro(Erros, Grupo, Format('CFOP %s incompatível com o tipo e o destino da operação ' +
          '(esperado iniciar com %s)', [Det.Prod.CFOP, DigitosValidos]));
      if (Nota.Ide.finNFe = fnDevolucao) and not EhCFOPDevolucao(Det.Prod.CFOP) then
        AdicionarErro(Avisos, Grupo, Format('CFOP %s não é de devolução', [Det.Prod.CFOP]));
    end;
    // complementar e ajuste podem ter só valor, sem quantidade
    if not (Nota.Ide.finNFe in [fnComplementar, fnAjuste]) then
    begin
      if Det.Prod.qCom <= 0 then
        AdicionarErro(Erros, Grupo, 'quantidade deve ser maior que zero');
      if Det.Prod.vUnCom <= 0 then
        AdicionarErro(Erros, Grupo, 'valor unitário deve ser maior que zero');
    end;
    if (Det.pDevol < 0) or (Det.pDevol > 100) then
      AdicionarErro(Erros, Grupo, 'percentual devolvido deve estar entre 0 e 100');
    if (Det.vIPIDevol > 0) and (Nota.Ide.finNFe <> fnDevolucao) then
      AdicionarErro(Erros, Grupo, 'IPI devolvido só pode ser informado em nota de devolução');
  end;
end;

procedure TEmissaoNFe.ValidarPagamentos(Erros: TStrings);
const
  GRUPO = 'Pagamento';
var
  Nota: TNFe;
  Pag: TpagCollectionItem;
  I: integer;
begin
  Nota := NFe;
  for I := 0 to Nota.pag.Count - 1 do
  begin
    Pag := Nota.pag[I];
    // devolução já é validada pelo ACBr (871); o ajuste segue a mesma regra do MOC
    if (Nota.Ide.finNFe = fnAjuste) and (Pag.tPag <> fpSemPagamento) then
      AdicionarErro(Erros, GRUPO, 'nota de ajuste deve usar "90 - Sem pagamento"');
    if (Pag.tPag = fpSemPagamento) and (Pag.vPag <> 0) then
      AdicionarErro(Erros, GRUPO, '"90 - Sem pagamento" deve ter valor zero');
    if (Pag.tPag = fpOutro) and (Trim(Pag.xPag) = '') then
      AdicionarErro(Erros, GRUPO, '"99 - Outros" exige a descrição do meio de pagamento');
    if (Pag.tPag in [fpCartaoCredito, fpCartaoDebito]) and (Pag.tpIntegra = tiNaoInformado) then
      AdicionarErro(Erros, GRUPO, 'pagamento com cartão exige o tipo de integração');
  end;
end;

procedure TEmissaoNFe.ValidarRegrasACBr(Erros: TStrings);
var
  Nota: NotaFiscal;
  Lista: TStringList;
  I: integer;
begin
  Nota := FACBrNFe.NotasFiscais[0];
  // gera a chave/ID usados pelas regras (ex.: 253, dígito da chave)
  Nota.GerarXML;
  if Nota.ValidarRegrasdeNegocios then
    Exit;
  Lista := TStringList.Create;
  try
    Lista.Text := Nota.ErroRegrasdeNegocios;
    // só as linhas de rejeição ("724-Rejeição: ..."); o ACBr inclui um cabeçalho com a contagem
    for I := 0 to Lista.Count - 1 do
      if (Trim(Lista[I]) <> '') and (Trim(Lista[I])[1] in ['0'..'9']) then
        AdicionarErro(Erros, 'SEFAZ', Trim(Lista[I]));
  finally
    Lista.Free;
  end;
end;

function TEmissaoNFe.Validar(Erros, Avisos: TStrings): Boolean;
begin
  Erros.Clear;
  Avisos.Clear;
  ValidarIdentificacao(Erros);
  ValidarEmitente(Erros);
  ValidarDestinatario(Erros);
  ValidarItens(Erros, Avisos);
  ValidarPagamentos(Erros);
  ValidarRegrasACBr(Erros);
  Result := Erros.Count = 0;
end;

procedure TEmissaoNFe.PrepararEnvio;
begin
  // exige o certificado digital; a validação de schema só é possível com a nota assinada
  FACBrNFe.NotasFiscais.Assinar;
  FACBrNFe.NotasFiscais.Validar;
end;

procedure TEmissaoNFe.EnviarSEFAZ;
begin
  // síncrono: a NFC-e exige e, para uma única NF-e, evita a consulta do recibo
  FACBrNFe.Enviar(IntToStr(NFe.Ide.nNF), False, True);
end;

function TEmissaoNFe.Emitir: TResultadoEmissao;
var
  Nota: NotaFiscal;
begin
  VerificarACBrNFe;
  Nota := FACBrNFe.NotasFiscais[0];
  Nota.GerarXML;
  PrepararEnvio;
  EnviarSEFAZ;
  Result.cStat := Nota.NFe.procNFe.cStat;
  Result.xMotivo := Nota.NFe.procNFe.xMotivo;
  if Result.cStat = 0 then
  begin
    Result.cStat := FACBrNFe.WebServices.Enviar.cStat;
    Result.xMotivo := FACBrNFe.WebServices.Enviar.xMotivo;
  end;
  Result.Chave := OnlyNumber(Nota.NFe.infNFe.ID);
  Result.Protocolo := Nota.NFe.procNFe.nProt;
  // 100: autorizada; 150: autorizada fora do prazo
  Result.Autorizada := Result.cStat in [100, 150];
end;

end.
