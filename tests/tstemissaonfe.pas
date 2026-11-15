unit tstemissaonfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, IniFiles, ACBrNFe, ACBrNFe.Classes, uemissaonfe;

type

  { TEmissaoNFeMock }

  // substitui certificado e webservice: não assina e devolve o retorno configurado
  TEmissaoNFeMock = class(TEmissaoNFe)
  private
    FEnvios: integer;
    FcStatRetorno: integer;
    FxMotivoRetorno: string;
  protected
    procedure PrepararEnvio; override;
    procedure EnviarSEFAZ; override;
  public
    property Envios: integer read FEnvios;
    property cStatRetorno: integer read FcStatRetorno write FcStatRetorno;
    property xMotivoRetorno: string read FxMotivoRetorno write FxMotivoRetorno;
  end;

  { TTesteEmissaoNFe }

  TTesteEmissaoNFe = class(TTestCase)
  private
    FACBrNFe: TACBrNFe;
    FEmissao: TEmissaoNFeMock;
    FIni: TMemIniFile;
    FErros: TStringList;
    FAvisos: TStringList;
    FPasta: string;
    procedure MontarNotaValida;
    function ContemErro(Lista: TStrings; const Trecho: string): Boolean;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestNovaNotaPreencheEmitente;
    procedure TestNovaNotaNFCeConformeConfiguracao;
    procedure TestRegrasModeloNFCe;
    procedure TestRegrasModeloNFe;
    procedure TestRegrasFinalidadeDevolucao;
    procedure TestDestinoOperacao;
    procedure TestNovoItemPadroes;
    procedure TestNovoItemSimplesNacional;
    procedure TestCalcularItem;
    procedure TestCalcularItemComST;
    procedure TestCalcularTotais;
    procedure TestNotaValida;
    procedure TestCFOPIncompativel;
    procedure TestDevolucaoSemReferencia;
    procedure TestAjusteComPagamento;
    procedure TestInscricaoEstadualDestinatario;
    procedure TestIntermediador;
    procedure TestNotaCreditoSemTipo;
    procedure TestSalvarECarregarXML;
    procedure TestEmitirAutorizada;
    procedure TestEmitirRejeitada;
  end;

implementation

uses
  FileUtil, pcnConversao, pcnConversaoNFe;

const
  SECAO = 'Emitente';

{ TEmissaoNFeMock }

procedure TEmissaoNFeMock.PrepararEnvio;
begin
end;

procedure TEmissaoNFeMock.EnviarSEFAZ;
begin
  Inc(FEnvios);
  NFe.procNFe.cStat := FcStatRetorno;
  NFe.procNFe.xMotivo := FxMotivoRetorno;
  if FcStatRetorno = 100 then
    NFe.procNFe.nProt := '135260000000001';
end;

{ TTesteEmissaoNFe }

procedure TTesteEmissaoNFe.SetUp;
begin
  FPasta := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'nfestudio-teste-emissao-' +
    IntToStr(GetProcessID) + PathDelim;
  DeleteDirectory(FPasta, False);
  ForceDirectories(FPasta);

  FACBrNFe := TACBrNFe.Create(nil);
  FACBrNFe.Configuracoes.Geral.ModeloDF := moNFe;
  FACBrNFe.Configuracoes.Geral.VersaoDF := ve400;
  FACBrNFe.Configuracoes.Geral.FormaEmissao := teNormal;
  FACBrNFe.Configuracoes.WebServices.UF := 'SP';
  FACBrNFe.Configuracoes.WebServices.Ambiente := taHomologacao;

  // dados do emitente do XML de exemplo (CNPJ e IE válidos em SP)
  FIni := TMemIniFile.Create('');
  FIni.WriteString(SECAO, 'CNPJCPF', '05481336000137');
  FIni.WriteString(SECAO, 'IE', '687138770110');
  FIni.WriteString(SECAO, 'RazaoSocial', 'D.J. SYSTEM CONSULTORIA LTDA - ME');
  FIni.WriteString(SECAO, 'Fantasia', 'DJSYSTEM');
  FIni.WriteInteger(SECAO, 'CRT', 3);
  FIni.WriteString(SECAO, 'Fone', '1533243333');
  FIni.WriteString(SECAO, 'CEP', '18270000');
  FIni.WriteString(SECAO, 'Logradouro', 'Rua Cel. Aureliano de Camargo');
  FIni.WriteString(SECAO, 'Numero', '973');
  FIni.WriteString(SECAO, 'Bairro', 'Centro');
  FIni.WriteInteger(SECAO, 'CodMunicipio', 3554003);
  FIni.WriteString(SECAO, 'Municipio', 'Tatui');
  FIni.WriteString(SECAO, 'UF', 'SP');

  FEmissao := TEmissaoNFeMock.Create(nil);
  FEmissao.ACBrNFe := FACBrNFe;
  FErros := TStringList.Create;
  FAvisos := TStringList.Create;
end;

procedure TTesteEmissaoNFe.TearDown;
begin
  FAvisos.Free;
  FErros.Free;
  FEmissao.Free;
  FIni.Free;
  FACBrNFe.Free;
  DeleteDirectory(FPasta, False);
end;

procedure TTesteEmissaoNFe.MontarNotaValida;
var
  Nota: TNFe;
  Det: TDetCollectionItem;
  Pag: TpagCollectionItem;
begin
  FEmissao.NovaNota(FIni);
  Nota := FEmissao.NFe;
  Nota.Ide.nNF := 123;
  Nota.Ide.indFinal := cfConsumidorFinal;
  Nota.Dest.CNPJCPF := '12345678909';
  Nota.Dest.xNome := 'CONSUMIDOR DE TESTE';
  Nota.Dest.indIEDest := inNaoContribuinte;
  Nota.Dest.EnderDest.xLgr := 'Rua das Flores';
  Nota.Dest.EnderDest.nro := '10';
  Nota.Dest.EnderDest.xBairro := 'Centro';
  Nota.Dest.EnderDest.cMun := 3554003;
  Nota.Dest.EnderDest.xMun := 'Tatui';
  Nota.Dest.EnderDest.UF := 'SP';
  Nota.Dest.EnderDest.CEP := 18270170;

  Det := FEmissao.NovoItem;
  Det.Prod.cProd := '001';
  Det.Prod.xProd := 'PRODUTO DE TESTE';
  Det.Prod.NCM := '84713012';
  Det.Prod.uCom := 'UN';
  Det.Prod.qCom := 2;
  Det.Prod.vUnCom := 10.5;
  Det.Imposto.ICMS.pICMS := 18;
  Det.Imposto.PIS.pPIS := 1.65;
  Det.Imposto.COFINS.pCOFINS := 7.6;
  FEmissao.CalcularItem(Det);
  FEmissao.CalcularTotais;

  Pag := Nota.pag.New;
  Pag.indPag := ipVista;
  Pag.tPag := fpDinheiro;
  Pag.vPag := Nota.Total.ICMSTot.vNF;
end;

function TTesteEmissaoNFe.ContemErro(Lista: TStrings; const Trecho: string): Boolean;
var
  I: integer;
begin
  for I := 0 to Lista.Count - 1 do
    if Pos(Trecho, Lista[I]) > 0 then
      Exit(True);
  Result := False;
end;

procedure TTesteEmissaoNFe.TestNovaNotaPreencheEmitente;
var
  Nota: TNFe;
begin
  FEmissao.NovaNota(FIni);
  Nota := FEmissao.NFe;
  AssertEquals('CNPJ', '05481336000137', Nota.Emit.CNPJCPF);
  AssertEquals('IE', '687138770110', Nota.Emit.IE);
  AssertEquals('razão social', 'D.J. SYSTEM CONSULTORIA LTDA - ME', Nota.Emit.xNome);
  AssertTrue('CRT regime normal', Nota.Emit.CRT = crtRegimeNormal);
  AssertEquals('CEP', 18270000, Nota.Emit.EnderEmit.CEP);
  AssertEquals('município', 3554003, Nota.Emit.EnderEmit.cMun);
  AssertEquals('país', 1058, Nota.Emit.EnderEmit.cPais);
  AssertEquals('UF da nota segue o emitente', 35, Nota.Ide.cUF);
  AssertEquals('município do fato gerador', 3554003, Nota.Ide.cMunFG);
  AssertEquals('modelo da configuração', MODELO_NFE, Nota.Ide.modelo);
  AssertTrue('ambiente da configuração', Nota.Ide.tpAmb = taHomologacao);
  AssertEquals('versão do aplicativo', 'NFeStudio', Nota.Ide.verProc);
  AssertEquals('cNF gerado pelo ACBr', 0, Nota.Ide.cNF);
end;

procedure TTesteEmissaoNFe.TestNovaNotaNFCeConformeConfiguracao;
var
  Nota: TNFe;
begin
  FACBrNFe.Configuracoes.Geral.ModeloDF := moNFCe;
  FEmissao.NovaNota(FIni);
  Nota := FEmissao.NFe;
  AssertEquals('modelo', MODELO_NFCE, Nota.Ide.modelo);
  AssertTrue('DANFE NFC-e', Nota.Ide.tpImp = tiNFCe);
  AssertTrue('consumidor final', Nota.Ide.indFinal = cfConsumidorFinal);
end;

procedure TTesteEmissaoNFe.TestRegrasModeloNFCe;
var
  Nota: TNFe;
begin
  FEmissao.NovaNota(FIni);
  Nota := FEmissao.NFe;
  Nota.Ide.tpNF := tnEntrada;
  Nota.Ide.idDest := doInterestadual;
  Nota.Ide.finNFe := fnDevolucao;
  Nota.Ide.indPres := pcInternet;
  Nota.Ide.tpEmis := teSVCAN;
  Nota.Ide.NFref.New.refNFe := '35150905481336000137550010000111291000111298';
  Nota.Dest.indIEDest := inContribuinte;
  Nota.Dest.IE := '687138770110';
  Nota.Cobr.Dup.New.nDup := '001';
  Nota.Transp.modFrete := mfContaEmitente;

  Nota.Ide.modelo := MODELO_NFCE;
  FEmissao.AplicarRegrasModelo;
  AssertTrue('saída', Nota.Ide.tpNF = tnSaida);
  AssertTrue('interna', Nota.Ide.idDest = doInterna);
  AssertTrue('finalidade normal', Nota.Ide.finNFe = fnNormal);
  AssertTrue('presencial', Nota.Ide.indPres = pcPresencial);
  AssertTrue('sem SVC', Nota.Ide.tpEmis = teNormal);
  AssertTrue('DANFE NFC-e', Nota.Ide.tpImp = tiNFCe);
  AssertEquals('sem referências', 0, Nota.Ide.NFref.Count);
  AssertTrue('destinatário não contribuinte', Nota.Dest.indIEDest = inNaoContribuinte);
  AssertEquals('sem IE do destinatário', '', Nota.Dest.IE);
  AssertEquals('sem duplicatas', 0, Nota.Cobr.Dup.Count);
  AssertTrue('sem frete', Nota.Transp.modFrete = mfSemFrete);
end;

procedure TTesteEmissaoNFe.TestRegrasModeloNFe;
var
  Nota: TNFe;
begin
  FACBrNFe.Configuracoes.Geral.ModeloDF := moNFCe;
  FEmissao.NovaNota(FIni);
  Nota := FEmissao.NFe;
  Nota.Ide.indPres := pcEntregaDomicilio;
  Nota.Ide.tpEmis := teOffLine;
  Nota.Ide.modelo := MODELO_NFE;
  FEmissao.AplicarRegrasModelo;
  AssertTrue('DANFE retrato', Nota.Ide.tpImp = tiRetrato);
  AssertTrue('entrega a domicílio é só NFC-e', Nota.Ide.indPres = pcPresencial);
  AssertTrue('off-line é só NFC-e', Nota.Ide.tpEmis = teNormal);
end;

procedure TTesteEmissaoNFe.TestRegrasFinalidadeDevolucao;
var
  Nota: TNFe;
begin
  MontarNotaValida;
  Nota := FEmissao.NFe;
  Nota.Ide.tpNFDebito := tdMultaJuros;
  Nota.Ide.finNFe := fnDevolucao;
  FEmissao.AplicarRegrasFinalidade;
  AssertEquals('um pagamento', 1, Nota.pag.Count);
  AssertTrue('sem pagamento', Nota.pag[0].tPag = fpSemPagamento);
  AssertEquals('valor zero', 0, Nota.pag[0].vPag, 0.001);
  AssertTrue('tipo de débito limpo', Nota.Ide.tpNFDebito = tdNenhum);

  Nota.Det[0].pDevol := 100;
  Nota.Ide.finNFe := fnNormal;
  FEmissao.AplicarRegrasFinalidade;
  AssertEquals('percentual devolvido limpo fora da devolução', 0, Nota.Det[0].pDevol, 0.001);
end;

procedure TTesteEmissaoNFe.TestDestinoOperacao;
var
  Nota: TNFe;
begin
  FEmissao.NovaNota(FIni);
  Nota := FEmissao.NFe;
  Nota.Ide.indPres := pcInternet;
  Nota.Dest.EnderDest.UF := 'RJ';
  FEmissao.DefinirDestinoOperacao;
  AssertTrue('interestadual', Nota.Ide.idDest = doInterestadual);
  Nota.Ide.indPres := pcPresencial;
  FEmissao.DefinirDestinoOperacao;
  AssertTrue('presencial é interna', Nota.Ide.idDest = doInterna);
  Nota.Dest.EnderDest.UF := 'EX';
  FEmissao.DefinirDestinoOperacao;
  AssertTrue('exterior', Nota.Ide.idDest = doExterior);
  Nota.Ide.indPres := pcInternet;
  Nota.Dest.EnderDest.UF := 'SP';
  FEmissao.DefinirDestinoOperacao;
  AssertTrue('mesma UF', Nota.Ide.idDest = doInterna);
end;

procedure TTesteEmissaoNFe.TestNovoItemPadroes;
var
  Det: TDetCollectionItem;
begin
  FEmissao.NovaNota(FIni);
  Det := FEmissao.NovoItem;
  AssertEquals('número do item', 1, Det.Prod.nItem);
  AssertEquals('CFOP de venda interna', '5102', Det.Prod.CFOP);
  AssertEquals('GTIN', 'SEM GTIN', Det.Prod.cEAN);
  AssertTrue('CST 00', Det.Imposto.ICMS.CST = cst00);
  AssertTrue('PIS 01', Det.Imposto.PIS.CST = pis01);
  AssertTrue('soma no total', Det.Prod.IndTot = itSomaTotalNFe);

  Det.Prod.CFOP := '5405';
  Det.Imposto.ICMS.CST := cst60;
  Det := FEmissao.NovoItem;
  AssertEquals('segundo item', 2, Det.Prod.nItem);
  AssertEquals('repete o CFOP anterior', '5405', Det.Prod.CFOP);
  AssertTrue('repete o CST anterior', Det.Imposto.ICMS.CST = cst60);

  FEmissao.NFe.Det.Clear;
  FEmissao.NFe.Ide.idDest := doInterestadual;
  AssertEquals('CFOP interestadual', '6102', FEmissao.NovoItem.Prod.CFOP);
end;

procedure TTesteEmissaoNFe.TestNovoItemSimplesNacional;
var
  Det: TDetCollectionItem;
begin
  FIni.WriteInteger(SECAO, 'CRT', 1);
  FEmissao.NovaNota(FIni);
  Det := FEmissao.NovoItem;
  AssertTrue('CSOSN 102', Det.Imposto.ICMS.CSOSN = csosn102);
  AssertTrue('PIS 49', Det.Imposto.PIS.CST = pis49);
end;

procedure TTesteEmissaoNFe.TestCalcularItem;
var
  Det: TDetCollectionItem;
begin
  FEmissao.NovaNota(FIni);
  Det := FEmissao.NovoItem;
  Det.Prod.uCom := 'UN';
  Det.Prod.qCom := 2;
  Det.Prod.vUnCom := 10.5;
  Det.Imposto.ICMS.pICMS := 18;
  Det.Imposto.PIS.pPIS := 1.65;
  Det.Imposto.IBSCBS.gIBSCBS.gCBS.pCBS := 0.9;
  FEmissao.CalcularItem(Det);
  AssertEquals('vProd', 21, Det.Prod.vProd, 0.001);
  AssertEquals('quantidade tributável', 2, Det.Prod.qTrib, 0.0001);
  AssertEquals('unidade tributável', 'UN', Det.Prod.uTrib);
  AssertEquals('base ICMS', 21, Det.Imposto.ICMS.vBC, 0.001);
  AssertEquals('ICMS', 3.78, Det.Imposto.ICMS.vICMS, 0.001);
  AssertEquals('PIS arredondado', 0.35, Det.Imposto.PIS.vPIS, 0.001);
  AssertEquals('base IBS/CBS', 21, Det.Imposto.IBSCBS.gIBSCBS.vBC, 0.001);
  AssertEquals('CBS', 0.19, Det.Imposto.IBSCBS.gIBSCBS.gCBS.vCBS, 0.001);
end;

procedure TTesteEmissaoNFe.TestCalcularItemComST;
var
  Det: TDetCollectionItem;
begin
  FEmissao.NovaNota(FIni);
  Det := FEmissao.NovoItem;
  Det.Prod.qCom := 1;
  Det.Prod.vUnCom := 100;
  Det.Imposto.ICMS.CST := cst10;
  Det.Imposto.ICMS.pICMS := 18;
  Det.Imposto.ICMS.pMVAST := 40;
  Det.Imposto.ICMS.pICMSST := 18;
  FEmissao.CalcularItem(Det);
  AssertEquals('ICMS próprio', 18, Det.Imposto.ICMS.vICMS, 0.001);
  AssertEquals('base ST com MVA', 140, Det.Imposto.ICMS.vBCST, 0.001);
  AssertEquals('ST descontado o próprio', 7.2, Det.Imposto.ICMS.vICMSST, 0.001);

  // isenta: nenhum ICMS calculado mesmo com alíquota informada
  Det.Imposto.ICMS.CST := cst40;
  Det.Imposto.ICMS.vBC := 0;
  Det.Imposto.ICMS.vICMS := 0;
  FEmissao.CalcularItem(Det);
  AssertEquals('isenta', 0, Det.Imposto.ICMS.vICMS, 0.001);
end;

procedure TTesteEmissaoNFe.TestCalcularTotais;
var
  Nota: TNFe;
  Det: TDetCollectionItem;
begin
  FEmissao.NovaNota(FIni);
  Nota := FEmissao.NFe;
  Det := FEmissao.NovoItem;
  Det.Prod.vProd := 100;
  Det.Prod.vFrete := 10;
  Det.Prod.vDesc := 5;
  Det.Imposto.ICMS.vBC := 105;
  Det.Imposto.ICMS.vICMS := 18.9;
  Det.Imposto.IPI.vIPI := 10;
  Det.Imposto.ICMS.vICMSST := 3;
  Det := FEmissao.NovoItem;
  // item que não compõe o total: entra nos tributos gerais, mas não em vProd/ICMS
  Det.Prod.IndTot := itNaoSomaTotalNFe;
  Det.Prod.vProd := 50;
  Det.Imposto.ICMS.vICMS := 9;
  Det.Imposto.PIS.vPIS := 1;
  FEmissao.CalcularTotais;
  AssertEquals('vProd', 100, Nota.Total.ICMSTot.vProd, 0.001);
  AssertEquals('vICMS', 18.9, Nota.Total.ICMSTot.vICMS, 0.001);
  AssertEquals('vPIS de todos os itens', 1, Nota.Total.ICMSTot.vPIS, 0.001);
  // 100 + ST 3 + frete 10 + IPI 10 - desconto 5
  AssertEquals('vNF', 118, Nota.Total.ICMSTot.vNF, 0.001);

  Nota.pag.New.vPag := 120;
  FEmissao.CalcularTotais;
  AssertEquals('troco', 2, Nota.pag.vTroco, 0.001);
end;

procedure TTesteEmissaoNFe.TestNotaValida;
begin
  MontarNotaValida;
  if not FEmissao.Validar(FErros, FAvisos) then
    Fail('nota deveria ser válida: ' + FErros.Text);
  AssertEquals('sem avisos', 0, FAvisos.Count);
  AssertEquals('chave gerada', 47, Length(FEmissao.NFe.infNFe.ID));
end;

procedure TTesteEmissaoNFe.TestCFOPIncompativel;
begin
  MontarNotaValida;
  FEmissao.NFe.Det[0].Prod.CFOP := '1102';
  AssertFalse(FEmissao.Validar(FErros, FAvisos));
  AssertTrue('CFOP de entrada em saída', ContemErro(FErros, 'CFOP 1102 incompatível'));
  FEmissao.NFe.Det[0].Prod.CFOP := '6102';
  FEmissao.Validar(FErros, FAvisos);
  AssertTrue('CFOP interestadual em operação interna', ContemErro(FErros, 'CFOP 6102 incompatível'));
end;

procedure TTesteEmissaoNFe.TestDevolucaoSemReferencia;
begin
  MontarNotaValida;
  FEmissao.NFe.Ide.finNFe := fnDevolucao;
  FEmissao.AplicarRegrasFinalidade;
  AssertFalse(FEmissao.Validar(FErros, FAvisos));
  AssertTrue('321 do ACBr', ContemErro(FErros, '321'));
  AssertTrue('aviso de CFOP de devolução', ContemErro(FAvisos, 'CFOP 5102 não é de devolução'));

  FEmissao.NFe.Ide.NFref.New.refNFe := '35150905481336000137550010000111291000111298';
  FEmissao.NFe.Det[0].Prod.CFOP := '5202';
  FEmissao.CalcularTotais;
  FEmissao.Validar(FErros, FAvisos);
  AssertFalse('com referência', ContemErro(FErros, '321'));
  AssertEquals('CFOP de devolução sem aviso', 0, FAvisos.Count);
end;

procedure TTesteEmissaoNFe.TestAjusteComPagamento;
begin
  MontarNotaValida;
  FEmissao.NFe.Ide.finNFe := fnAjuste;
  AssertFalse(FEmissao.Validar(FErros, FAvisos));
  AssertTrue('ajuste exige sem pagamento', ContemErro(FErros, 'nota de ajuste deve usar "90 - Sem pagamento"'));
  FEmissao.AplicarRegrasFinalidade;
  FEmissao.Validar(FErros, FAvisos);
  AssertFalse('corrigido pela regra de finalidade', ContemErro(FErros, 'nota de ajuste'));
end;

procedure TTesteEmissaoNFe.TestInscricaoEstadualDestinatario;
begin
  MontarNotaValida;
  FEmissao.NFe.Dest.CNPJCPF := '05481336000137';
  FEmissao.NFe.Dest.indIEDest := inContribuinte;
  FEmissao.Validar(FErros, FAvisos);
  AssertTrue('contribuinte sem IE', ContemErro(FErros, 'contribuinte do ICMS sem inscrição estadual'));
  FEmissao.NFe.Dest.indIEDest := inIsento;
  FEmissao.NFe.Dest.IE := '687138770110';
  FEmissao.Validar(FErros, FAvisos);
  AssertTrue('isento com IE', ContemErro(FErros, 'isento não deve informar'));
  FEmissao.NFe.Dest.indIEDest := inNaoContribuinte;
  FEmissao.NFe.Dest.IE := '';
  FEmissao.NFe.Ide.indFinal := cfNao;
  FEmissao.Validar(FErros, FAvisos);
  AssertTrue('696: não contribuinte é consumidor final', ContemErro(FErros, 'deve indicar consumidor final'));
end;

procedure TTesteEmissaoNFe.TestIntermediador;
begin
  MontarNotaValida;
  FEmissao.NFe.Ide.indPres := pcInternet;
  FEmissao.Validar(FErros, FAvisos);
  AssertTrue('obrigatório na internet', ContemErro(FErros, 'indicador de intermediador obrigatório'));
  FEmissao.NFe.Ide.indIntermed := iiOperacaoComIntermediador;
  FEmissao.Validar(FErros, FAvisos);
  AssertTrue('CNPJ do intermediador', ContemErro(FErros, 'CNPJ do intermediador inválido'));
  FEmissao.NFe.Ide.indPres := pcPresencial;
  FEmissao.Validar(FErros, FAvisos);
  AssertTrue('não cabe em presencial', ContemErro(FErros, 'só pode ser informado em operação não presencial'));
end;

procedure TTesteEmissaoNFe.TestNotaCreditoSemTipo;
begin
  MontarNotaValida;
  FEmissao.NFe.Ide.finNFe := fnCredito;
  FEmissao.Validar(FErros, FAvisos);
  AssertTrue('tipo de crédito', ContemErro(FErros, 'nota de crédito sem o tipo de crédito'));
  FEmissao.NFe.Ide.tpNFCredito := tcMultaJuros;
  FEmissao.Validar(FErros, FAvisos);
  AssertFalse('tipo informado', ContemErro(FErros, 'sem o tipo de crédito'));
end;

procedure TTesteEmissaoNFe.TestSalvarECarregarXML;
var
  Arquivo: string;
begin
  MontarNotaValida;
  FEmissao.NFe.InfAdic.infCpl := 'Teste de rascunho';
  Arquivo := FPasta + 'rascunho.xml';
  FEmissao.SalvarXML(Arquivo);
  AssertTrue('arquivo gravado', FileExists(Arquivo));

  FEmissao.NovaNota(FIni);
  FEmissao.CarregarXML(Arquivo);
  AssertEquals('número', 123, FEmissao.NFe.Ide.nNF);
  // em homologação o ACBr grava o nome exigido pela SEFAZ no lugar do destinatário
  AssertEquals('destinatário em homologação', 'NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL',
    FEmissao.NFe.Dest.xNome);
  AssertEquals('itens', 1, FEmissao.NFe.Det.Count);
  AssertEquals('ICMS do item', 3.78, FEmissao.NFe.Det[0].Imposto.ICMS.vICMS, 0.001);
  AssertEquals('informações complementares', 'Teste de rascunho', FEmissao.NFe.InfAdic.infCpl);
  AssertEquals('pagamento', 1, FEmissao.NFe.pag.Count);

  FEmissao.NFe.Ide.tpAmb := taProducao;
  FEmissao.NFe.Dest.xNome := 'CONSUMIDOR DE TESTE';
  FEmissao.SalvarXML(Arquivo);
  FEmissao.CarregarXML(Arquivo);
  AssertEquals('destinatário em produção', 'CONSUMIDOR DE TESTE', FEmissao.NFe.Dest.xNome);
end;

procedure TTesteEmissaoNFe.TestEmitirAutorizada;
var
  Resultado: TResultadoEmissao;
begin
  MontarNotaValida;
  FEmissao.cStatRetorno := 100;
  FEmissao.xMotivoRetorno := 'Autorizado o uso da NF-e';
  Resultado := FEmissao.Emitir;
  AssertEquals('enviada uma vez', 1, FEmissao.Envios);
  AssertTrue('autorizada', Resultado.Autorizada);
  AssertEquals('protocolo', '135260000000001', Resultado.Protocolo);
  AssertEquals('chave', 44, Length(Resultado.Chave));
end;

procedure TTesteEmissaoNFe.TestEmitirRejeitada;
var
  Resultado: TResultadoEmissao;
begin
  MontarNotaValida;
  FEmissao.cStatRetorno := 539;
  FEmissao.xMotivoRetorno := 'Rejeição: Duplicidade de NF-e';
  Resultado := FEmissao.Emitir;
  AssertFalse('não autorizada', Resultado.Autorizada);
  AssertEquals('cStat', 539, Resultado.cStat);
  AssertEquals('motivo', 'Rejeição: Duplicidade de NF-e', Resultado.xMotivo);
  AssertEquals('sem protocolo', '', Resultado.Protocolo);
end;

initialization
  RegisterTest(TTesteEmissaoNFe);

end.
