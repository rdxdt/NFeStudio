unit uprocessadornfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ACBrNFe, ACBrNFe.Classes;

type

  { TProcessadorNFe }

  TProcessadorNFe = class(TComponent)
  private
    FACBrNFe: TACBrNFe;
    FLog: TStringList;
    function GetLog: TStrings;
    procedure SetACBrNFe(AValue: TACBrNFe);
    procedure ImportarDiretorio(const Diretorio: string; var Quantidade: integer);
    procedure ImportarArquivo(const Arquivo: string; var Quantidade: integer);
    function ObterChave(NFe: TNFe): string;
    procedure GravarNFe(NFe: TNFe; const Chave: string);
    procedure ExcluirNFe(const Chave: string);
    procedure GravarCabecalho(NFe: TNFe; const Chave: string);
    procedure GravarItens(NFe: TNFe; const Chave: string);
    procedure GravarFatura(NFe: TNFe; const Chave: string);
    procedure GravarDuplicatas(NFe: TNFe; const Chave: string);
    procedure GravarVolumes(NFe: TNFe; const Chave: string);
    procedure GravarPagamentos(NFe: TNFe; const Chave: string);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Importar(const Diretorio: string): integer;
    property Log: TStrings read GetLog;
  published
    property ACBrNFe: TACBrNFe read FACBrNFe write SetACBrNFe;
  end;

implementation

uses
  StrUtils, ZAbstractConnection, pcnConversao, pcnConversaoNFe, ACBrDFe.Conversao,
  udmdnfe;

const
  TAMANHO_CHAVE = 44;
  PREFIXO_ID = 'NFe';
  EXTENSAO_XML = '.xml';
  MSG_SEM_ACBRNFE = 'Componente ACBrNFe não atribuído ao processador';
  MSG_DIRETORIO_INEXISTENTE = 'Diretório não encontrado: %s';
  MSG_ERRO_LEITURA = '%s: arquivo ignorado, não foi possível ler a NFe (%s)';
  MSG_SEM_NFE = '%s: arquivo ignorado, não contém NFe';
  MSG_SEM_CHAVE = '%s: NFe ignorada, sem CHNFE';
  MSG_ERRO_GRAVACAO = '%s: erro ao gravar a NFe %s (%s)';

procedure LimparParametros(Q: TZQuery);
var
  I: integer;
begin
  // as queries são reutilizadas entre notas; parâmetros não atribuídos devem ir como NULL
  for I := 0 to Q.Params.Count - 1 do
    Q.Params[I].Clear;
end;

procedure AtribuirTexto(Q: TZQuery; const Nome, Valor: string);
begin
  if Valor = '' then
    Q.ParamByName(Nome).Clear
  else
    Q.ParamByName(Nome).AsString := Valor;
end;

procedure AtribuirInteiro(Q: TZQuery; const Nome: string; Valor: integer);
begin
  Q.ParamByName(Nome).AsInteger := Valor;
end;

procedure AtribuirInteiroOpcional(Q: TZQuery; const Nome: string; Valor: integer);
begin
  // para códigos como CEP e município, zero indica tag ausente no XML
  if Valor = 0 then
    Q.ParamByName(Nome).Clear
  else
    Q.ParamByName(Nome).AsInteger := Valor;
end;

procedure AtribuirNumero(Q: TZQuery; const Nome: string; Valor: double);
begin
  Q.ParamByName(Nome).AsFloat := Valor;
end;

procedure AtribuirDataHora(Q: TZQuery; const Nome: string; Valor: TDateTime);
begin
  if Valor = 0 then
    Q.ParamByName(Nome).Clear
  else
    Q.ParamByName(Nome).AsDateTime := Valor;
end;

procedure AtribuirData(Q: TZQuery; const Nome: string; Valor: TDateTime);
begin
  if Valor = 0 then
    Q.ParamByName(Nome).Clear
  else
    Q.ParamByName(Nome).AsDate := Valor;
end;

procedure AtribuirHora(Q: TZQuery; const Nome: string; Valor: TDateTime);
begin
  if Valor = 0 then
    Q.ParamByName(Nome).Clear
  else
    Q.ParamByName(Nome).AsTime := Valor;
end;

{ TProcessadorNFe }

constructor TProcessadorNFe.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLog := TStringList.Create;
end;

destructor TProcessadorNFe.Destroy;
begin
  FLog.Free;
  inherited Destroy;
end;

function TProcessadorNFe.GetLog: TStrings;
begin
  Result := FLog;
end;

procedure TProcessadorNFe.SetACBrNFe(AValue: TACBrNFe);
begin
  if FACBrNFe = AValue then
    Exit;
  if Assigned(FACBrNFe) then
    FACBrNFe.RemoveFreeNotification(Self);
  FACBrNFe := AValue;
  if Assigned(FACBrNFe) then
    FACBrNFe.FreeNotification(Self);
end;

procedure TProcessadorNFe.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FACBrNFe) then
    FACBrNFe := nil;
end;

function TProcessadorNFe.Importar(const Diretorio: string): integer;
begin
  if not Assigned(FACBrNFe) then
    raise Exception.Create(MSG_SEM_ACBRNFE);
  if not DirectoryExists(Diretorio) then
    raise Exception.CreateFmt(MSG_DIRETORIO_INEXISTENTE, [Diretorio]);

  FLog.Clear;
  Result := 0;
  try
    ImportarDiretorio(Diretorio, Result);
  finally
    FACBrNFe.NotasFiscais.Clear;
  end;
end;

procedure TProcessadorNFe.ImportarDiretorio(const Diretorio: string; var Quantidade: integer);
var
  Busca: TSearchRec;
  Caminho: string;
begin
  Caminho := IncludeTrailingPathDelimiter(Diretorio);
  if FindFirst(Caminho + '*', faAnyFile, Busca) <> 0 then
    Exit;
  try
    repeat
      if (Busca.Name = '.') or (Busca.Name = '..') then
        Continue;
      if (Busca.Attr and faDirectory) <> 0 then
      begin
        // links simbólicos de diretório são ignorados para evitar recursão infinita
        if (Busca.Attr and faSymLink{%H-}) = 0 then
          ImportarDiretorio(Caminho + Busca.Name, Quantidade);
      end
      else if SameText(ExtractFileExt(Busca.Name), EXTENSAO_XML) then
        ImportarArquivo(Caminho + Busca.Name, Quantidade);
    until FindNext(Busca) <> 0;
  finally
    FindClose(Busca);
  end;
end;

procedure TProcessadorNFe.ImportarArquivo(const Arquivo: string; var Quantidade: integer);
var
  I: integer;
  NFe: TNFe;
  Chave: string;
begin
  FACBrNFe.NotasFiscais.Clear;
  try
    FACBrNFe.NotasFiscais.LoadFromFile(Arquivo);
  except
    on E: Exception do
    begin
      FLog.Add(Format(MSG_ERRO_LEITURA, [Arquivo, E.Message]));
      Exit;
    end;
  end;

  if FACBrNFe.NotasFiscais.Count = 0 then
  begin
    FLog.Add(Format(MSG_SEM_NFE, [Arquivo]));
    Exit;
  end;

  // um arquivo de lote (enviNFe) pode conter várias notas
  for I := 0 to FACBrNFe.NotasFiscais.Count - 1 do
  begin
    NFe := FACBrNFe.NotasFiscais[I].NFe;
    Chave := ObterChave(NFe);
    if Chave = '' then
    begin
      FLog.Add(Format(MSG_SEM_CHAVE, [Arquivo]));
      Continue;
    end;
    try
      GravarNFe(NFe, Chave);
      Inc(Quantidade);
    except
      on E: Exception do
        FLog.Add(Format(MSG_ERRO_GRAVACAO, [Arquivo, Chave, E.Message]));
    end;
  end;
end;

function TProcessadorNFe.ObterChave(NFe: TNFe): string;
begin
  // infNFe.ID vem do atributo Id do XML, no formato 'NFe' + chave de acesso
  Result := Trim(NFe.infNFe.ID);
  if StartsText(PREFIXO_ID, Result) then
    Delete(Result, 1, Length(PREFIXO_ID));
  if Length(Result) <> TAMANHO_CHAVE then
    Result := '';
end;

procedure TProcessadorNFe.GravarNFe(NFe: TNFe; const Chave: string);
var
  Conexao: TZAbstractConnection;
begin
  Conexao := dmdNFe.cmdInsNFeCab.Connection;
  Conexao.StartTransaction;
  try
    // reimportar uma nota substitui a versão gravada (ex.: XML com protocolo de autorização)
    ExcluirNFe(Chave);
    GravarCabecalho(NFe, Chave);
    GravarItens(NFe, Chave);
    GravarFatura(NFe, Chave);
    GravarDuplicatas(NFe, Chave);
    GravarVolumes(NFe, Chave);
    GravarPagamentos(NFe, Chave);
    Conexao.Commit;
  except
    Conexao.Rollback;
    raise;
  end;
end;

procedure TProcessadorNFe.ExcluirNFe(const Chave: string);
var
  Comandos: array of TZQuery;
  Q: TZQuery;
begin
  // o ON DELETE CASCADE depende de PRAGMA foreign_keys, por isso cada tabela é excluída explicitamente
  Comandos := [dmdNFe.cmdDelNFeDet, dmdNFe.cmdDelNFeFat, dmdNFe.cmdDelNFeDup,
    dmdNFe.cmdDelNFeVol, dmdNFe.cmdDelNFePgt, dmdNFe.cmdDelNFeCab];
  for Q in Comandos do
  begin
    Q.ParamByName('CHNFE').AsString := Chave;
    Q.ExecSQL;
  end;
end;

procedure TProcessadorNFe.GravarCabecalho(NFe: TNFe; const Chave: string);
var
  Q: TZQuery;
begin
  Q := dmdNFe.cmdInsNFeCab;
  LimparParametros(Q);
  AtribuirTexto(Q, 'CHNFE', Chave);
  AtribuirNumero(Q, 'VERSAO', NFe.infNFe.Versao);
  AtribuirInteiro(Q, 'IDE_CUF', NFe.Ide.cUF);
  AtribuirInteiro(Q, 'IDE_CNF', NFe.Ide.cNF);
  AtribuirTexto(Q, 'IDE_NATOP', NFe.Ide.natOp);
  AtribuirTexto(Q, 'IDE_INDPAG', IndpagToStrEX(NFe.Ide.indPag));
  AtribuirInteiro(Q, 'IDE_MOD', NFe.Ide.modelo);
  AtribuirInteiro(Q, 'IDE_SERIE', NFe.Ide.serie);
  AtribuirInteiro(Q, 'IDE_NNF', NFe.Ide.nNF);
  AtribuirDataHora(Q, 'IDE_DHEMI', NFe.Ide.dEmi);
  AtribuirDataHora(Q, 'IDE_DHSAIENT', NFe.Ide.dSaiEnt);
  AtribuirHora(Q, 'IDE_HSAIENT', NFe.Ide.hSaiEnt);
  AtribuirTexto(Q, 'IDE_TPNF', tpNFToStr(NFe.Ide.tpNF));
  AtribuirTexto(Q, 'IDE_IDDEST', DestinoOperacaoToStr(NFe.Ide.idDest));
  AtribuirInteiro(Q, 'IDE_CMUNFG', NFe.Ide.cMunFG);
  AtribuirTexto(Q, 'IDE_TPIMP', TpImpToStr(NFe.Ide.tpImp));
  AtribuirTexto(Q, 'IDE_TPEMIS', TpEmisToStr(NFe.Ide.tpEmis));
  AtribuirInteiro(Q, 'IDE_CDV', NFe.Ide.cDV);
  AtribuirTexto(Q, 'IDE_TPAMB', TpAmbToStr(NFe.Ide.tpAmb));
  AtribuirTexto(Q, 'IDE_FINNFE', FinNFeToStr(NFe.Ide.finNFe));
  AtribuirTexto(Q, 'IDE_INDFINAL', ConsumidorFinalToStr(NFe.Ide.indFinal));
  AtribuirTexto(Q, 'IDE_INDPRES', PresencaCompradorToStr(NFe.Ide.indPres));
  AtribuirTexto(Q, 'IDE_INDINTERMED', IndIntermedToStr(NFe.Ide.indIntermed));
  AtribuirTexto(Q, 'IDE_PROCEMI', procEmiToStr(NFe.Ide.procEmi));
  AtribuirTexto(Q, 'IDE_VERPROC', NFe.Ide.verProc);
  AtribuirDataHora(Q, 'IDE_DHCONT', NFe.Ide.dhCont);
  AtribuirTexto(Q, 'IDE_XJUST', NFe.Ide.xJust);
  AtribuirInteiroOpcional(Q, 'IDE_CMUNFGIBS', NFe.Ide.cMunFGIBS);
  AtribuirTexto(Q, 'IDE_TPNFDEBITO', tpNFDebitoToStr(NFe.Ide.tpNFDebito));
  AtribuirTexto(Q, 'IDE_TPNFCREDITO', tpNFCreditoToStr(NFe.Ide.tpNFCredito));
  if NFe.Ide.gCompraGov.tpEnteGov <> tcgNenhum then
  begin
    AtribuirTexto(Q, 'COMPRAGOV_TPENTEGOV', tpEnteGovToStr(NFe.Ide.gCompraGov.tpEnteGov));
    AtribuirNumero(Q, 'COMPRAGOV_PREDUTOR', NFe.Ide.gCompraGov.pRedutor);
    AtribuirTexto(Q, 'COMPRAGOV_TPOPERGOV', tpOperGovToStr(NFe.Ide.gCompraGov.tpOperGov));
  end;
  AtribuirTexto(Q, 'EMIT_CNPJCPF', NFe.Emit.CNPJCPF);
  AtribuirTexto(Q, 'EMIT_XNOME', NFe.Emit.xNome);
  AtribuirTexto(Q, 'EMIT_XFANT', NFe.Emit.xFant);
  AtribuirTexto(Q, 'EMIT_XLGR', NFe.Emit.EnderEmit.xLgr);
  AtribuirTexto(Q, 'EMIT_NRO', NFe.Emit.EnderEmit.nro);
  AtribuirTexto(Q, 'EMIT_XCPL', NFe.Emit.EnderEmit.xCpl);
  AtribuirTexto(Q, 'EMIT_XBAIRRO', NFe.Emit.EnderEmit.xBairro);
  AtribuirInteiro(Q, 'EMIT_CMUN', NFe.Emit.EnderEmit.cMun);
  AtribuirTexto(Q, 'EMIT_XMUN', NFe.Emit.EnderEmit.xMun);
  AtribuirTexto(Q, 'EMIT_UF', NFe.Emit.EnderEmit.UF);
  AtribuirInteiroOpcional(Q, 'EMIT_CEP', NFe.Emit.EnderEmit.CEP);
  AtribuirInteiroOpcional(Q, 'EMIT_CPAIS', NFe.Emit.EnderEmit.cPais);
  AtribuirTexto(Q, 'EMIT_XPAIS', NFe.Emit.EnderEmit.xPais);
  AtribuirTexto(Q, 'EMIT_FONE', NFe.Emit.EnderEmit.fone);
  AtribuirTexto(Q, 'EMIT_IE', NFe.Emit.IE);
  AtribuirTexto(Q, 'EMIT_IEST', NFe.Emit.IEST);
  AtribuirTexto(Q, 'EMIT_IM', NFe.Emit.IM);
  AtribuirTexto(Q, 'EMIT_CNAE', NFe.Emit.CNAE);
  AtribuirTexto(Q, 'EMIT_CRT', CRTToStr(NFe.Emit.CRT));
  if NFe.Avulsa.CNPJ <> '' then
  begin
    AtribuirTexto(Q, 'AVULSA_CNPJ', NFe.Avulsa.CNPJ);
    AtribuirTexto(Q, 'AVULSA_XORGAO', NFe.Avulsa.xOrgao);
    AtribuirTexto(Q, 'AVULSA_MATR', NFe.Avulsa.matr);
    AtribuirTexto(Q, 'AVULSA_XAGENTE', NFe.Avulsa.xAgente);
    AtribuirTexto(Q, 'AVULSA_FONE', NFe.Avulsa.fone);
    AtribuirTexto(Q, 'AVULSA_UF', NFe.Avulsa.UF);
    AtribuirTexto(Q, 'AVULSA_NDAR', NFe.Avulsa.nDAR);
    AtribuirData(Q, 'AVULSA_DEMI', NFe.Avulsa.dEmi);
    AtribuirNumero(Q, 'AVULSA_VDAR', NFe.Avulsa.vDAR);
    AtribuirTexto(Q, 'AVULSA_REPEMI', NFe.Avulsa.repEmi);
    AtribuirData(Q, 'AVULSA_DPAG', NFe.Avulsa.dPag);
  end;
  if (NFe.Dest.CNPJCPF <> '') or (NFe.Dest.idEstrangeiro <> '') or (NFe.Dest.xNome <> '') then
  begin
    AtribuirTexto(Q, 'DEST_CNPJCPF', NFe.Dest.CNPJCPF);
    AtribuirTexto(Q, 'DEST_IDESTRANGEIRO', NFe.Dest.idEstrangeiro);
    AtribuirTexto(Q, 'DEST_XNOME', NFe.Dest.xNome);
    AtribuirTexto(Q, 'DEST_XLGR', NFe.Dest.EnderDest.xLgr);
    AtribuirTexto(Q, 'DEST_NRO', NFe.Dest.EnderDest.nro);
    AtribuirTexto(Q, 'DEST_XCPL', NFe.Dest.EnderDest.xCpl);
    AtribuirTexto(Q, 'DEST_XBAIRRO', NFe.Dest.EnderDest.xBairro);
    AtribuirInteiroOpcional(Q, 'DEST_CMUN', NFe.Dest.EnderDest.cMun);
    AtribuirTexto(Q, 'DEST_XMUN', NFe.Dest.EnderDest.xMun);
    AtribuirTexto(Q, 'DEST_UF', NFe.Dest.EnderDest.UF);
    AtribuirInteiroOpcional(Q, 'DEST_CEP', NFe.Dest.EnderDest.CEP);
    AtribuirInteiroOpcional(Q, 'DEST_CPAIS', NFe.Dest.EnderDest.cPais);
    AtribuirTexto(Q, 'DEST_XPAIS', NFe.Dest.EnderDest.xPais);
    AtribuirTexto(Q, 'DEST_FONE', NFe.Dest.EnderDest.fone);
    AtribuirTexto(Q, 'DEST_INDIEDEST', indIEDestToStr(NFe.Dest.indIEDest));
    AtribuirTexto(Q, 'DEST_IE', NFe.Dest.IE);
    AtribuirTexto(Q, 'DEST_ISUF', NFe.Dest.ISUF);
    AtribuirTexto(Q, 'DEST_IM', NFe.Dest.IM);
    AtribuirTexto(Q, 'DEST_EMAIL', NFe.Dest.Email);
  end;
  if NFe.Retirada.xLgr <> '' then
  begin
    AtribuirTexto(Q, 'RETIRADA_CNPJCPF', NFe.Retirada.CNPJCPF);
    AtribuirTexto(Q, 'RETIRADA_XNOME', NFe.Retirada.xNome);
    AtribuirTexto(Q, 'RETIRADA_XLGR', NFe.Retirada.xLgr);
    AtribuirTexto(Q, 'RETIRADA_NRO', NFe.Retirada.nro);
    AtribuirTexto(Q, 'RETIRADA_XCPL', NFe.Retirada.xCpl);
    AtribuirTexto(Q, 'RETIRADA_XBAIRRO', NFe.Retirada.xBairro);
    AtribuirInteiroOpcional(Q, 'RETIRADA_CMUN', NFe.Retirada.cMun);
    AtribuirTexto(Q, 'RETIRADA_XMUN', NFe.Retirada.xMun);
    AtribuirTexto(Q, 'RETIRADA_UF', NFe.Retirada.UF);
    AtribuirInteiroOpcional(Q, 'RETIRADA_CEP', NFe.Retirada.CEP);
    AtribuirInteiroOpcional(Q, 'RETIRADA_CPAIS', NFe.Retirada.cPais);
    AtribuirTexto(Q, 'RETIRADA_XPAIS', NFe.Retirada.xPais);
    AtribuirTexto(Q, 'RETIRADA_FONE', NFe.Retirada.fone);
    AtribuirTexto(Q, 'RETIRADA_EMAIL', NFe.Retirada.Email);
    AtribuirTexto(Q, 'RETIRADA_IE', NFe.Retirada.IE);
  end;
  if NFe.Entrega.xLgr <> '' then
  begin
    AtribuirTexto(Q, 'ENTREGA_CNPJCPF', NFe.Entrega.CNPJCPF);
    AtribuirTexto(Q, 'ENTREGA_XNOME', NFe.Entrega.xNome);
    AtribuirTexto(Q, 'ENTREGA_XLGR', NFe.Entrega.xLgr);
    AtribuirTexto(Q, 'ENTREGA_NRO', NFe.Entrega.nro);
    AtribuirTexto(Q, 'ENTREGA_XCPL', NFe.Entrega.xCpl);
    AtribuirTexto(Q, 'ENTREGA_XBAIRRO', NFe.Entrega.xBairro);
    AtribuirInteiroOpcional(Q, 'ENTREGA_CMUN', NFe.Entrega.cMun);
    AtribuirTexto(Q, 'ENTREGA_XMUN', NFe.Entrega.xMun);
    AtribuirTexto(Q, 'ENTREGA_UF', NFe.Entrega.UF);
    AtribuirInteiroOpcional(Q, 'ENTREGA_CEP', NFe.Entrega.CEP);
    AtribuirInteiroOpcional(Q, 'ENTREGA_CPAIS', NFe.Entrega.cPais);
    AtribuirTexto(Q, 'ENTREGA_XPAIS', NFe.Entrega.xPais);
    AtribuirTexto(Q, 'ENTREGA_FONE', NFe.Entrega.fone);
    AtribuirTexto(Q, 'ENTREGA_EMAIL', NFe.Entrega.Email);
    AtribuirTexto(Q, 'ENTREGA_IE', NFe.Entrega.IE);
  end;
  AtribuirNumero(Q, 'TOT_VBC', NFe.Total.ICMSTot.vBC);
  AtribuirNumero(Q, 'TOT_VICMS', NFe.Total.ICMSTot.vICMS);
  AtribuirNumero(Q, 'TOT_VICMSDESON', NFe.Total.ICMSTot.vICMSDeson);
  AtribuirNumero(Q, 'TOT_VFCPUFDEST', NFe.Total.ICMSTot.vFCPUFDest);
  AtribuirNumero(Q, 'TOT_VICMSUFDEST', NFe.Total.ICMSTot.vICMSUFDest);
  AtribuirNumero(Q, 'TOT_VICMSUFREMET', NFe.Total.ICMSTot.vICMSUFRemet);
  AtribuirNumero(Q, 'TOT_VFCP', NFe.Total.ICMSTot.vFCP);
  AtribuirNumero(Q, 'TOT_VBCST', NFe.Total.ICMSTot.vBCST);
  AtribuirNumero(Q, 'TOT_VST', NFe.Total.ICMSTot.vST);
  AtribuirNumero(Q, 'TOT_VFCPST', NFe.Total.ICMSTot.vFCPST);
  AtribuirNumero(Q, 'TOT_VFCPSTRET', NFe.Total.ICMSTot.vFCPSTRet);
  AtribuirNumero(Q, 'TOT_VPROD', NFe.Total.ICMSTot.vProd);
  AtribuirNumero(Q, 'TOT_VFRETE', NFe.Total.ICMSTot.vFrete);
  AtribuirNumero(Q, 'TOT_VSEG', NFe.Total.ICMSTot.vSeg);
  AtribuirNumero(Q, 'TOT_VDESC', NFe.Total.ICMSTot.vDesc);
  AtribuirNumero(Q, 'TOT_VII', NFe.Total.ICMSTot.vII);
  AtribuirNumero(Q, 'TOT_VIPI', NFe.Total.ICMSTot.vIPI);
  AtribuirNumero(Q, 'TOT_VIPIDEVOL', NFe.Total.ICMSTot.vIPIDevol);
  AtribuirNumero(Q, 'TOT_VPIS', NFe.Total.ICMSTot.vPIS);
  AtribuirNumero(Q, 'TOT_VCOFINS', NFe.Total.ICMSTot.vCOFINS);
  AtribuirNumero(Q, 'TOT_VOUTRO', NFe.Total.ICMSTot.vOutro);
  AtribuirNumero(Q, 'TOT_VNF', NFe.Total.ICMSTot.vNF);
  AtribuirNumero(Q, 'TOT_VTOTTRIB', NFe.Total.ICMSTot.vTotTrib);
  AtribuirNumero(Q, 'TOT_VICMSMONO', NFe.Total.ICMSTot.vICMSMono);
  AtribuirNumero(Q, 'TOT_VICMSMONORETEN', NFe.Total.ICMSTot.vICMSMonoReten);
  AtribuirNumero(Q, 'TOT_VICMSMONORET', NFe.Total.ICMSTot.vICMSMonoRet);
  AtribuirNumero(Q, 'TOT_QBCMONO', NFe.Total.ICMSTot.qBCMono);
  AtribuirNumero(Q, 'TOT_QBCMONORETEN', NFe.Total.ICMSTot.qBCMonoReten);
  AtribuirNumero(Q, 'TOT_QBCMONORET', NFe.Total.ICMSTot.qBCMonoRet);
  AtribuirNumero(Q, 'TOT_VNFTOT', NFe.Total.vNFTot);
  AtribuirNumero(Q, 'ISSQNTOT_VSERV', NFe.Total.ISSQNtot.vServ);
  AtribuirNumero(Q, 'ISSQNTOT_VBC', NFe.Total.ISSQNtot.vBC);
  AtribuirNumero(Q, 'ISSQNTOT_VISS', NFe.Total.ISSQNtot.vISS);
  AtribuirNumero(Q, 'ISSQNTOT_VPIS', NFe.Total.ISSQNtot.vPIS);
  AtribuirNumero(Q, 'ISSQNTOT_VCOFINS', NFe.Total.ISSQNtot.vCOFINS);
  AtribuirData(Q, 'ISSQNTOT_DCOMPET', NFe.Total.ISSQNtot.dCompet);
  AtribuirNumero(Q, 'ISSQNTOT_VDEDUCAO', NFe.Total.ISSQNtot.vDeducao);
  AtribuirNumero(Q, 'ISSQNTOT_VOUTRO', NFe.Total.ISSQNtot.vOutro);
  AtribuirNumero(Q, 'ISSQNTOT_VDESCINCOND', NFe.Total.ISSQNtot.vDescIncond);
  AtribuirNumero(Q, 'ISSQNTOT_VDESCCOND', NFe.Total.ISSQNtot.vDescCond);
  AtribuirNumero(Q, 'ISSQNTOT_VISSRET', NFe.Total.ISSQNtot.vISSRet);
  if NFe.Total.ISSQNtot.cRegTrib <> RTISSNenhum then
  begin
    AtribuirTexto(Q, 'ISSQNTOT_CREGTRIB', RegTribISSQNToStr(NFe.Total.ISSQNtot.cRegTrib));
  end;
  AtribuirNumero(Q, 'RETTRIB_VRETPIS', NFe.Total.retTrib.vRetPIS);
  AtribuirNumero(Q, 'RETTRIB_VRETCOFINS', NFe.Total.retTrib.vRetCOFINS);
  AtribuirNumero(Q, 'RETTRIB_VRETCSLL', NFe.Total.retTrib.vRetCSLL);
  AtribuirNumero(Q, 'RETTRIB_VBCIRRF', NFe.Total.retTrib.vBCIRRF);
  AtribuirNumero(Q, 'RETTRIB_VIRRF', NFe.Total.retTrib.vIRRF);
  AtribuirNumero(Q, 'RETTRIB_VBCRETPREV', NFe.Total.retTrib.vBCRetPrev);
  AtribuirNumero(Q, 'RETTRIB_VRETPREV', NFe.Total.retTrib.vRetPrev);
  AtribuirNumero(Q, 'ISTOT_VIS', NFe.Total.ISTot.vIS);
  AtribuirNumero(Q, 'IBSCBSTOT_VBCIBSCBS', NFe.Total.IBSCBSTot.vBCIBSCBS);
  AtribuirNumero(Q, 'IBSUFTOT_VDIF', NFe.Total.IBSCBSTot.gIBS.gIBSUFTot.vDif);
  AtribuirNumero(Q, 'IBSUFTOT_VDEVTRIB', NFe.Total.IBSCBSTot.gIBS.gIBSUFTot.vDevTrib);
  AtribuirNumero(Q, 'IBSUFTOT_VIBSUF', NFe.Total.IBSCBSTot.gIBS.gIBSUFTot.vIBSUF);
  AtribuirNumero(Q, 'IBSMUNTOT_VDIF', NFe.Total.IBSCBSTot.gIBS.gIBSMunTot.vDif);
  AtribuirNumero(Q, 'IBSMUNTOT_VDEVTRIB', NFe.Total.IBSCBSTot.gIBS.gIBSMunTot.vDevTrib);
  AtribuirNumero(Q, 'IBSMUNTOT_VIBSMUN', NFe.Total.IBSCBSTot.gIBS.gIBSMunTot.vIBSMun);
  AtribuirNumero(Q, 'IBSTOT_VIBS', NFe.Total.IBSCBSTot.gIBS.vIBS);
  AtribuirNumero(Q, 'IBSTOT_VCREDPRES', NFe.Total.IBSCBSTot.gIBS.vCredPres);
  AtribuirNumero(Q, 'IBSTOT_VCREDPRESCONDSUS', NFe.Total.IBSCBSTot.gIBS.vCredPresCondSus);
  AtribuirNumero(Q, 'CBSTOT_VDIF', NFe.Total.IBSCBSTot.gCBS.vDif);
  AtribuirNumero(Q, 'CBSTOT_VDEVTRIB', NFe.Total.IBSCBSTot.gCBS.vDevTrib);
  AtribuirNumero(Q, 'CBSTOT_VCBS', NFe.Total.IBSCBSTot.gCBS.vCBS);
  AtribuirNumero(Q, 'CBSTOT_VCREDPRES', NFe.Total.IBSCBSTot.gCBS.vCredPres);
  AtribuirNumero(Q, 'CBSTOT_VCREDPRESCONDSUS', NFe.Total.IBSCBSTot.gCBS.vCredPresCondSus);
  AtribuirNumero(Q, 'MONOTOT_VIBSMONO', NFe.Total.IBSCBSTot.gMono.vIBSMono);
  AtribuirNumero(Q, 'MONOTOT_VCBSMONO', NFe.Total.IBSCBSTot.gMono.vCBSMono);
  AtribuirNumero(Q, 'MONOTOT_VIBSMONORETEN', NFe.Total.IBSCBSTot.gMono.vIBSMonoReten);
  AtribuirNumero(Q, 'MONOTOT_VCBSMONORETEN', NFe.Total.IBSCBSTot.gMono.vCBSMonoReten);
  AtribuirNumero(Q, 'MONOTOT_VIBSMONORET', NFe.Total.IBSCBSTot.gMono.vIBSMonoRet);
  AtribuirNumero(Q, 'MONOTOT_VCBSMONORET', NFe.Total.IBSCBSTot.gMono.vCBSMonoRet);
  AtribuirTexto(Q, 'TRANSP_MODFRETE', modFreteToStr(NFe.Transp.modFrete));
  AtribuirTexto(Q, 'TRANSPORTA_CNPJCPF', NFe.Transp.Transporta.CNPJCPF);
  AtribuirTexto(Q, 'TRANSPORTA_XNOME', NFe.Transp.Transporta.xNome);
  AtribuirTexto(Q, 'TRANSPORTA_IE', NFe.Transp.Transporta.IE);
  AtribuirTexto(Q, 'TRANSPORTA_XENDER', NFe.Transp.Transporta.xEnder);
  AtribuirTexto(Q, 'TRANSPORTA_XMUN', NFe.Transp.Transporta.xMun);
  AtribuirTexto(Q, 'TRANSPORTA_UF', NFe.Transp.Transporta.UF);
  if (NFe.Transp.retTransp.vServ > 0) or (NFe.Transp.retTransp.CFOP <> '') then
  begin
    AtribuirNumero(Q, 'RETTRANSP_VSERV', NFe.Transp.retTransp.vServ);
    AtribuirNumero(Q, 'RETTRANSP_VBCRET', NFe.Transp.retTransp.vBCRet);
    AtribuirNumero(Q, 'RETTRANSP_PICMSRET', NFe.Transp.retTransp.pICMSRet);
    AtribuirNumero(Q, 'RETTRANSP_VICMSRET', NFe.Transp.retTransp.vICMSRet);
    AtribuirTexto(Q, 'RETTRANSP_CFOP', NFe.Transp.retTransp.CFOP);
    AtribuirInteiroOpcional(Q, 'RETTRANSP_CMUNFG', NFe.Transp.retTransp.cMunFG);
  end;
  AtribuirTexto(Q, 'VEICTRANSP_PLACA', NFe.Transp.veicTransp.placa);
  AtribuirTexto(Q, 'VEICTRANSP_UF', NFe.Transp.veicTransp.UF);
  AtribuirTexto(Q, 'VEICTRANSP_RNTC', NFe.Transp.veicTransp.RNTC);
  AtribuirTexto(Q, 'TRANSP_VAGAO', NFe.Transp.vagao);
  AtribuirTexto(Q, 'TRANSP_BALSA', NFe.Transp.balsa);
  AtribuirNumero(Q, 'PAG_VTROCO', NFe.pag.vTroco);
  AtribuirTexto(Q, 'INTERMED_CNPJ', NFe.infIntermed.CNPJ);
  AtribuirTexto(Q, 'INTERMED_IDCADINTTRAN', NFe.infIntermed.idCadIntTran);
  AtribuirTexto(Q, 'INFADIC_INFADFISCO', NFe.InfAdic.infAdFisco);
  AtribuirTexto(Q, 'INFADIC_INFCPL', NFe.InfAdic.infCpl);
  AtribuirTexto(Q, 'EXPORTA_UFEMBARQ', NFe.exporta.UFembarq);
  AtribuirTexto(Q, 'EXPORTA_XLOCEMBARQ', NFe.exporta.xLocEmbarq);
  AtribuirTexto(Q, 'EXPORTA_UFSAIDAPAIS', NFe.exporta.UFSaidaPais);
  AtribuirTexto(Q, 'EXPORTA_XLOCEXPORTA', NFe.exporta.xLocExporta);
  AtribuirTexto(Q, 'EXPORTA_XLOCDESPACHO', NFe.exporta.xLocDespacho);
  AtribuirTexto(Q, 'COMPRA_XNEMP', NFe.compra.xNEmp);
  AtribuirTexto(Q, 'COMPRA_XPED', NFe.compra.xPed);
  AtribuirTexto(Q, 'COMPRA_XCONT', NFe.compra.xCont);
  if NFe.cana.safra <> '' then
  begin
    AtribuirTexto(Q, 'CANA_SAFRA', NFe.cana.safra);
    AtribuirTexto(Q, 'CANA_REF', NFe.cana.ref);
    AtribuirNumero(Q, 'CANA_QTOTMES', NFe.cana.qTotMes);
    AtribuirNumero(Q, 'CANA_QTOTANT', NFe.cana.qTotAnt);
    AtribuirNumero(Q, 'CANA_QTOTGER', NFe.cana.qTotGer);
    AtribuirNumero(Q, 'CANA_VFOR', NFe.cana.vFor);
    AtribuirNumero(Q, 'CANA_VTOTDED', NFe.cana.vTotDed);
    AtribuirNumero(Q, 'CANA_VLIQFOR', NFe.cana.vLiqFor);
  end;
  if NFe.agropecuario.guiaTransito.tpGuia <> tpgNenhum then
  begin
    AtribuirTexto(Q, 'AGRO_UFGUIA', NFe.agropecuario.guiaTransito.UFGuia);
    AtribuirTexto(Q, 'AGRO_TPGUIA', TtpGuiaToStr(NFe.agropecuario.guiaTransito.tpGuia));
    AtribuirTexto(Q, 'AGRO_SERIEGUIA', NFe.agropecuario.guiaTransito.serieGuia);
    AtribuirTexto(Q, 'AGRO_NGUIA', NFe.agropecuario.guiaTransito.nGuia);
  end;
  AtribuirTexto(Q, 'SUPL_QRCODE', NFe.infNFeSupl.qrCode);
  AtribuirTexto(Q, 'SUPL_URLCHAVE', NFe.infNFeSupl.urlChave);
  AtribuirTexto(Q, 'RESPTEC_CNPJ', NFe.infRespTec.CNPJ);
  AtribuirTexto(Q, 'RESPTEC_XCONTATO', NFe.infRespTec.xContato);
  AtribuirTexto(Q, 'RESPTEC_EMAIL', NFe.infRespTec.email);
  AtribuirTexto(Q, 'RESPTEC_FONE', NFe.infRespTec.fone);
  AtribuirInteiroOpcional(Q, 'RESPTEC_IDCSRT', NFe.infRespTec.idCSRT);
  AtribuirTexto(Q, 'RESPTEC_HASHCSRT', NFe.infRespTec.hashCSRT);
  if (NFe.procNFe.nProt <> '') or (NFe.procNFe.cStat > 0) then
  begin
    AtribuirTexto(Q, 'PROT_TPAMB', TpAmbToStr(NFe.procNFe.tpAmb));
    AtribuirTexto(Q, 'PROT_VERAPLIC', NFe.procNFe.verAplic);
    AtribuirDataHora(Q, 'PROT_DHRECBTO', NFe.procNFe.dhRecbto);
    AtribuirTexto(Q, 'PROT_NPROT', NFe.procNFe.nProt);
    AtribuirTexto(Q, 'PROT_DIGVAL', NFe.procNFe.digVal);
    AtribuirInteiroOpcional(Q, 'PROT_CSTAT', NFe.procNFe.cStat);
    AtribuirTexto(Q, 'PROT_XMOTIVO', NFe.procNFe.xMotivo);
    AtribuirInteiroOpcional(Q, 'PROT_CMSG', NFe.procNFe.cMsg);
    AtribuirTexto(Q, 'PROT_XMSG', NFe.procNFe.xMsg);
  end;
  Q.ExecSQL;
end;

procedure TProcessadorNFe.GravarItens(NFe: TNFe; const Chave: string);
var
  Q: TZQuery;
  I: integer;
  Det: TDetCollectionItem;
begin
  Q := dmdNFe.cmdInsNFeDet;
  for I := 0 to NFe.Det.Count - 1 do
  begin
    Det := NFe.Det[I];
    LimparParametros(Q);
    AtribuirTexto(Q, 'CHNFE', Chave);
    AtribuirInteiro(Q, 'NITEM', Det.Prod.nItem);
    AtribuirTexto(Q, 'CPROD', Det.Prod.cProd);
    AtribuirTexto(Q, 'CEAN', Det.Prod.cEAN);
    AtribuirTexto(Q, 'CBARRA', Det.Prod.cBarra);
    AtribuirTexto(Q, 'XPROD', Det.Prod.xProd);
    AtribuirTexto(Q, 'NCM', Det.Prod.NCM);
    AtribuirTexto(Q, 'EXTIPI', Det.Prod.EXTIPI);
    AtribuirTexto(Q, 'CFOP', Det.Prod.CFOP);
    AtribuirTexto(Q, 'UCOM', Det.Prod.uCom);
    AtribuirNumero(Q, 'QCOM', Det.Prod.qCom);
    AtribuirNumero(Q, 'VUNCOM', Det.Prod.vUnCom);
    AtribuirNumero(Q, 'VPROD', Det.Prod.vProd);
    AtribuirTexto(Q, 'CEANTRIB', Det.Prod.cEANTrib);
    AtribuirTexto(Q, 'CBARRATRIB', Det.Prod.cBarraTrib);
    AtribuirTexto(Q, 'UTRIB', Det.Prod.uTrib);
    AtribuirNumero(Q, 'QTRIB', Det.Prod.qTrib);
    AtribuirNumero(Q, 'VUNTRIB', Det.Prod.vUnTrib);
    AtribuirNumero(Q, 'VFRETE', Det.Prod.vFrete);
    AtribuirNumero(Q, 'VSEG', Det.Prod.vSeg);
    AtribuirNumero(Q, 'VDESC', Det.Prod.vDesc);
    AtribuirNumero(Q, 'VOUTRO', Det.Prod.vOutro);
    AtribuirTexto(Q, 'INDTOT', indTotToStr(Det.Prod.IndTot));
    AtribuirTexto(Q, 'XPED', Det.Prod.xPed);
    AtribuirTexto(Q, 'NITEMPED', Det.Prod.nItemPed);
    AtribuirTexto(Q, 'NRECOPI', Det.Prod.nRECOPI);
    AtribuirTexto(Q, 'NFCI', Det.Prod.nFCI);
    AtribuirTexto(Q, 'CEST', Det.Prod.CEST);
    AtribuirTexto(Q, 'INDESCALA', IndEscalaToStr(Det.Prod.indEscala));
    AtribuirTexto(Q, 'CNPJFAB', Det.Prod.CNPJFab);
    AtribuirTexto(Q, 'CBENEF', Det.Prod.cBenef);
    AtribuirTexto(Q, 'INDBEMMOVELUSADO', TIndicadorExToStr(Det.Prod.indBemMovelUsado));
    if Det.Prod.veicProd.chassi <> '' then
    begin
      AtribuirTexto(Q, 'VEIC_TPOP', tpOPToStr(Det.Prod.veicProd.tpOP));
      AtribuirTexto(Q, 'VEIC_CHASSI', Det.Prod.veicProd.chassi);
      AtribuirTexto(Q, 'VEIC_CCOR', Det.Prod.veicProd.cCor);
      AtribuirTexto(Q, 'VEIC_XCOR', Det.Prod.veicProd.xCor);
      AtribuirTexto(Q, 'VEIC_POT', Det.Prod.veicProd.pot);
      AtribuirTexto(Q, 'VEIC_CILIN', Det.Prod.veicProd.Cilin);
      AtribuirTexto(Q, 'VEIC_PESOL', Det.Prod.veicProd.pesoL);
      AtribuirTexto(Q, 'VEIC_PESOB', Det.Prod.veicProd.pesoB);
      AtribuirTexto(Q, 'VEIC_NSERIE', Det.Prod.veicProd.nSerie);
      AtribuirTexto(Q, 'VEIC_TPCOMB', Det.Prod.veicProd.tpComb);
      AtribuirTexto(Q, 'VEIC_NMOTOR', Det.Prod.veicProd.nMotor);
      AtribuirTexto(Q, 'VEIC_CMT', Det.Prod.veicProd.CMT);
      AtribuirTexto(Q, 'VEIC_DIST', Det.Prod.veicProd.dist);
      AtribuirInteiroOpcional(Q, 'VEIC_ANOMOD', Det.Prod.veicProd.anoMod);
      AtribuirInteiroOpcional(Q, 'VEIC_ANOFAB', Det.Prod.veicProd.anoFab);
      AtribuirTexto(Q, 'VEIC_TPPINT', Det.Prod.veicProd.tpPint);
      AtribuirInteiroOpcional(Q, 'VEIC_TPVEIC', Det.Prod.veicProd.tpVeic);
      AtribuirInteiroOpcional(Q, 'VEIC_ESPVEIC', Det.Prod.veicProd.espVeic);
      AtribuirTexto(Q, 'VEIC_VIN', Det.Prod.veicProd.VIN);
      AtribuirTexto(Q, 'VEIC_CONDVEIC', condVeicToStr(Det.Prod.veicProd.condVeic));
      AtribuirTexto(Q, 'VEIC_CMOD', Det.Prod.veicProd.cMod);
      AtribuirTexto(Q, 'VEIC_CCORDENATRAN', Det.Prod.veicProd.cCorDENATRAN);
      AtribuirInteiroOpcional(Q, 'VEIC_LOTA', Det.Prod.veicProd.lota);
      AtribuirInteiroOpcional(Q, 'VEIC_TPREST', Det.Prod.veicProd.tpRest);
    end;
    if Det.Prod.comb.cProdANP > 0 then
    begin
      AtribuirInteiro(Q, 'COMB_CPRODANP', Det.Prod.comb.cProdANP);
      AtribuirNumero(Q, 'COMB_PMIXGN', Det.Prod.comb.pMixGN);
      AtribuirTexto(Q, 'COMB_DESCANP', Det.Prod.comb.descANP);
      AtribuirNumero(Q, 'COMB_PGLP', Det.Prod.comb.pGLP);
      AtribuirNumero(Q, 'COMB_PGNN', Det.Prod.comb.pGNn);
      AtribuirNumero(Q, 'COMB_PGNI', Det.Prod.comb.pGNi);
      AtribuirNumero(Q, 'COMB_VPART', Det.Prod.comb.vPart);
      AtribuirTexto(Q, 'COMB_CODIF', Det.Prod.comb.CODIF);
      AtribuirNumero(Q, 'COMB_QTEMP', Det.Prod.comb.qTemp);
      AtribuirTexto(Q, 'COMB_UFCONS', Det.Prod.comb.UFcons);
      AtribuirNumero(Q, 'COMB_PBIO', Det.Prod.comb.pBio);
      AtribuirNumero(Q, 'CIDE_QBCPROD', Det.Prod.comb.CIDE.qBCProd);
      AtribuirNumero(Q, 'CIDE_VALIQPROD', Det.Prod.comb.CIDE.vAliqProd);
      AtribuirNumero(Q, 'CIDE_VCIDE', Det.Prod.comb.CIDE.vCIDE);
      AtribuirNumero(Q, 'COMB_VBCICMS', Det.Prod.comb.ICMS.vBCICMS);
      AtribuirNumero(Q, 'COMB_VICMS', Det.Prod.comb.ICMS.vICMS);
      AtribuirNumero(Q, 'COMB_VBCICMSST', Det.Prod.comb.ICMS.vBCICMSST);
      AtribuirNumero(Q, 'COMB_VICMSST', Det.Prod.comb.ICMS.vICMSST);
      AtribuirNumero(Q, 'COMB_VBCICMSSTDEST', Det.Prod.comb.ICMSInter.vBCICMSSTDest);
      AtribuirNumero(Q, 'COMB_VICMSSTDEST', Det.Prod.comb.ICMSInter.vICMSSTDest);
      AtribuirNumero(Q, 'COMB_VBCICMSSTCONS', Det.Prod.comb.ICMSCons.vBCICMSSTCons);
      AtribuirNumero(Q, 'COMB_VICMSSTCONS', Det.Prod.comb.ICMSCons.vICMSSTCons);
      AtribuirTexto(Q, 'COMB_UFCONSST', Det.Prod.comb.ICMSCons.UFcons);
      AtribuirInteiroOpcional(Q, 'ENCERRANTE_NBICO', Det.Prod.comb.encerrante.nBico);
      AtribuirInteiroOpcional(Q, 'ENCERRANTE_NBOMBA', Det.Prod.comb.encerrante.nBomba);
      AtribuirInteiroOpcional(Q, 'ENCERRANTE_NTANQUE', Det.Prod.comb.encerrante.nTanque);
      AtribuirNumero(Q, 'ENCERRANTE_VENCINI', Det.Prod.comb.encerrante.vEncIni);
      AtribuirNumero(Q, 'ENCERRANTE_VENCFIN', Det.Prod.comb.encerrante.vEncFin);
    end;
    AtribuirNumero(Q, 'VTOTTRIB', Det.Imposto.vTotTrib);
    AtribuirTexto(Q, 'ICMS_ORIG', OrigToStr(Det.Imposto.ICMS.orig));
    // o grupo do ICMS usa CST no regime normal e CSOSN no Simples Nacional
    if NFe.Emit.CRT in [crtRegimeNormal, crtSimplesExcessoReceita] then
      AtribuirTexto(Q, 'ICMS_CST', CSTICMSToStr(Det.Imposto.ICMS.CST))
    else
      AtribuirTexto(Q, 'ICMS_CSOSN', CSOSNIcmsToStr(Det.Imposto.ICMS.CSOSN));
    AtribuirTexto(Q, 'ICMS_MODBC', modBCToStr(Det.Imposto.ICMS.modBC));
    AtribuirNumero(Q, 'ICMS_PREDBC', Det.Imposto.ICMS.pRedBC);
    AtribuirNumero(Q, 'ICMS_VBC', Det.Imposto.ICMS.vBC);
    AtribuirNumero(Q, 'ICMS_PICMS', Det.Imposto.ICMS.pICMS);
    AtribuirNumero(Q, 'ICMS_VICMS', Det.Imposto.ICMS.vICMS);
    AtribuirTexto(Q, 'ICMS_MODBCST', modBCSTToStr(Det.Imposto.ICMS.modBCST));
    AtribuirNumero(Q, 'ICMS_PMVAST', Det.Imposto.ICMS.pMVAST);
    AtribuirNumero(Q, 'ICMS_PREDBCST', Det.Imposto.ICMS.pRedBCST);
    AtribuirNumero(Q, 'ICMS_VBCST', Det.Imposto.ICMS.vBCST);
    AtribuirNumero(Q, 'ICMS_PICMSST', Det.Imposto.ICMS.pICMSST);
    AtribuirNumero(Q, 'ICMS_VICMSST', Det.Imposto.ICMS.vICMSST);
    AtribuirTexto(Q, 'ICMS_UFST', Det.Imposto.ICMS.UFST);
    AtribuirNumero(Q, 'ICMS_PBCOP', Det.Imposto.ICMS.pBCOp);
    AtribuirNumero(Q, 'ICMS_VBCSTRET', Det.Imposto.ICMS.vBCSTRet);
    AtribuirNumero(Q, 'ICMS_VICMSSTRET', Det.Imposto.ICMS.vICMSSTRet);
    if Det.Imposto.ICMS.vICMSDeson > 0 then
    begin
      AtribuirTexto(Q, 'ICMS_MOTDESICMS', motDesICMSToStr(Det.Imposto.ICMS.motDesICMS));
    end;
    AtribuirNumero(Q, 'ICMS_PCREDSN', Det.Imposto.ICMS.pCredSN);
    AtribuirNumero(Q, 'ICMS_VCREDICMSSN', Det.Imposto.ICMS.vCredICMSSN);
    AtribuirNumero(Q, 'ICMS_VBCSTDEST', Det.Imposto.ICMS.vBCSTDest);
    AtribuirNumero(Q, 'ICMS_VICMSSTDEST', Det.Imposto.ICMS.vICMSSTDest);
    AtribuirNumero(Q, 'ICMS_VICMSDESON', Det.Imposto.ICMS.vICMSDeson);
    AtribuirNumero(Q, 'ICMS_VICMSOP', Det.Imposto.ICMS.vICMSOp);
    AtribuirNumero(Q, 'ICMS_PDIF', Det.Imposto.ICMS.pDif);
    AtribuirNumero(Q, 'ICMS_VICMSDIF', Det.Imposto.ICMS.vICMSDif);
    AtribuirNumero(Q, 'ICMS_VBCFCP', Det.Imposto.ICMS.vBCFCP);
    AtribuirNumero(Q, 'ICMS_PFCP', Det.Imposto.ICMS.pFCP);
    AtribuirNumero(Q, 'ICMS_VFCP', Det.Imposto.ICMS.vFCP);
    AtribuirNumero(Q, 'ICMS_VBCFCPST', Det.Imposto.ICMS.vBCFCPST);
    AtribuirNumero(Q, 'ICMS_PFCPST', Det.Imposto.ICMS.pFCPST);
    AtribuirNumero(Q, 'ICMS_VFCPST', Det.Imposto.ICMS.vFCPST);
    AtribuirNumero(Q, 'ICMS_VBCFCPSTRET', Det.Imposto.ICMS.vBCFCPSTRet);
    AtribuirNumero(Q, 'ICMS_PFCPSTRET', Det.Imposto.ICMS.pFCPSTRet);
    AtribuirNumero(Q, 'ICMS_VFCPSTRET', Det.Imposto.ICMS.vFCPSTRet);
    AtribuirNumero(Q, 'ICMS_PST', Det.Imposto.ICMS.pST);
    AtribuirNumero(Q, 'ICMS_PREDBCEFET', Det.Imposto.ICMS.pRedBCEfet);
    AtribuirNumero(Q, 'ICMS_VBCEFET', Det.Imposto.ICMS.vBCEfet);
    AtribuirNumero(Q, 'ICMS_PICMSEFET', Det.Imposto.ICMS.pICMSEfet);
    AtribuirNumero(Q, 'ICMS_VICMSEFET', Det.Imposto.ICMS.vICMSEfet);
    AtribuirNumero(Q, 'ICMS_VICMSSUBSTITUTO', Det.Imposto.ICMS.vICMSSubstituto);
    AtribuirNumero(Q, 'ICMS_VICMSSTDESON', Det.Imposto.ICMS.vICMSSTDeson);
    if Det.Imposto.ICMS.vICMSSTDeson > 0 then
    begin
      AtribuirTexto(Q, 'ICMS_MOTDESICMSST', motDesICMSToStr(Det.Imposto.ICMS.motDesICMSST));
    end;
    AtribuirNumero(Q, 'ICMS_PFCPDIF', Det.Imposto.ICMS.pFCPDif);
    AtribuirNumero(Q, 'ICMS_VFCPDIF', Det.Imposto.ICMS.vFCPDif);
    AtribuirNumero(Q, 'ICMS_VFCPEFET', Det.Imposto.ICMS.vFCPEfet);
    AtribuirNumero(Q, 'ICMS_ADREMICMS', Det.Imposto.ICMS.adRemICMS);
    AtribuirNumero(Q, 'ICMS_VICMSMONO', Det.Imposto.ICMS.vICMSMono);
    AtribuirNumero(Q, 'ICMS_QBCMONO', Det.Imposto.ICMS.qBCMono);
    AtribuirNumero(Q, 'ICMS_ADREMICMSRETEN', Det.Imposto.ICMS.adRemICMSReten);
    AtribuirNumero(Q, 'ICMS_VICMSMONORETEN', Det.Imposto.ICMS.vICMSMonoReten);
    AtribuirNumero(Q, 'ICMS_QBCMONORETEN', Det.Imposto.ICMS.qBCMonoReten);
    AtribuirNumero(Q, 'ICMS_PREDADREM', Det.Imposto.ICMS.pRedAdRem);
    if Det.Imposto.ICMS.pRedAdRem > 0 then
    begin
      AtribuirTexto(Q, 'ICMS_MOTREDADREM', motRedAdRemToStr(Det.Imposto.ICMS.motRedAdRem));
    end;
    AtribuirNumero(Q, 'ICMS_VICMSMONOOP', Det.Imposto.ICMS.vICMSMonoOp);
    AtribuirNumero(Q, 'ICMS_VICMSMONODIF', Det.Imposto.ICMS.vICMSMonoDif);
    AtribuirNumero(Q, 'ICMS_ADREMICMSRET', Det.Imposto.ICMS.adRemICMSRet);
    AtribuirNumero(Q, 'ICMS_VICMSMONORET', Det.Imposto.ICMS.vICMSMonoRet);
    AtribuirNumero(Q, 'ICMS_QBCMONORET', Det.Imposto.ICMS.qBCMonoRet);
    AtribuirTexto(Q, 'ICMS_INDDEDUZDESON', TIndicadorExToStr(Det.Imposto.ICMS.indDeduzDeson));
    AtribuirTexto(Q, 'ICMS_CBENEFRBC', Det.Imposto.ICMS.cBenefRBC);
    if Det.Imposto.IPI.cEnq <> '' then
    begin
      AtribuirTexto(Q, 'IPI_CLENQ', Det.Imposto.IPI.clEnq);
      AtribuirTexto(Q, 'IPI_CNPJPROD', Det.Imposto.IPI.CNPJProd);
      AtribuirTexto(Q, 'IPI_CSELO', Det.Imposto.IPI.cSelo);
      AtribuirInteiroOpcional(Q, 'IPI_QSELO', Det.Imposto.IPI.qSelo);
      AtribuirTexto(Q, 'IPI_CENQ', Det.Imposto.IPI.cEnq);
      AtribuirTexto(Q, 'IPI_CST', CSTIPIToStr(Det.Imposto.IPI.CST));
      AtribuirNumero(Q, 'IPI_VBC', Det.Imposto.IPI.vBC);
      AtribuirNumero(Q, 'IPI_QUNID', Det.Imposto.IPI.qUnid);
      AtribuirNumero(Q, 'IPI_VUNID', Det.Imposto.IPI.vUnid);
      AtribuirNumero(Q, 'IPI_PIPI', Det.Imposto.IPI.pIPI);
      AtribuirNumero(Q, 'IPI_VIPI', Det.Imposto.IPI.vIPI);
    end;
    if (Det.Imposto.II.vBc > 0) or (Det.Imposto.II.vDespAdu > 0) or (Det.Imposto.II.vII > 0) or (Det.Imposto.II.vIOF > 0) then
    begin
      AtribuirNumero(Q, 'II_VBC', Det.Imposto.II.vBc);
      AtribuirNumero(Q, 'II_VDESPADU', Det.Imposto.II.vDespAdu);
      AtribuirNumero(Q, 'II_VII', Det.Imposto.II.vII);
      AtribuirNumero(Q, 'II_VIOF', Det.Imposto.II.vIOF);
    end;
    AtribuirTexto(Q, 'PIS_CST', CSTPISToStr(Det.Imposto.PIS.CST));
    AtribuirNumero(Q, 'PIS_VBC', Det.Imposto.PIS.vBC);
    AtribuirNumero(Q, 'PIS_PPIS', Det.Imposto.PIS.pPIS);
    AtribuirNumero(Q, 'PIS_VPIS', Det.Imposto.PIS.vPIS);
    AtribuirNumero(Q, 'PIS_QBCPROD', Det.Imposto.PIS.qBCProd);
    AtribuirNumero(Q, 'PIS_VALIQPROD', Det.Imposto.PIS.vAliqProd);
    if (Det.Imposto.PISST.vBc > 0) or (Det.Imposto.PISST.pPis > 0) or (Det.Imposto.PISST.qBCProd > 0) or (Det.Imposto.PISST.vPIS > 0) then
    begin
      AtribuirNumero(Q, 'PISST_VBC', Det.Imposto.PISST.vBc);
      AtribuirNumero(Q, 'PISST_PPIS', Det.Imposto.PISST.pPis);
      AtribuirNumero(Q, 'PISST_QBCPROD', Det.Imposto.PISST.qBCProd);
      AtribuirNumero(Q, 'PISST_VALIQPROD', Det.Imposto.PISST.vAliqProd);
      AtribuirNumero(Q, 'PISST_VPIS', Det.Imposto.PISST.vPIS);
      AtribuirTexto(Q, 'PISST_INDSOMAPISST', indSomaPISSTToStr(Det.Imposto.PISST.indSomaPISST));
    end;
    AtribuirTexto(Q, 'COFINS_CST', CSTCOFINSToStr(Det.Imposto.COFINS.CST));
    AtribuirNumero(Q, 'COFINS_VBC', Det.Imposto.COFINS.vBC);
    AtribuirNumero(Q, 'COFINS_PCOFINS', Det.Imposto.COFINS.pCOFINS);
    AtribuirNumero(Q, 'COFINS_VCOFINS', Det.Imposto.COFINS.vCOFINS);
    AtribuirNumero(Q, 'COFINS_VBCPROD', Det.Imposto.COFINS.vBCProd);
    AtribuirNumero(Q, 'COFINS_QBCPROD', Det.Imposto.COFINS.qBCProd);
    AtribuirNumero(Q, 'COFINS_VALIQPROD', Det.Imposto.COFINS.vAliqProd);
    if (Det.Imposto.COFINSST.vBC > 0) or (Det.Imposto.COFINSST.pCOFINS > 0) or (Det.Imposto.COFINSST.qBCProd > 0) or (Det.Imposto.COFINSST.vCOFINS > 0) then
    begin
      AtribuirNumero(Q, 'COFINSST_VBC', Det.Imposto.COFINSST.vBC);
      AtribuirNumero(Q, 'COFINSST_PCOFINS', Det.Imposto.COFINSST.pCOFINS);
      AtribuirNumero(Q, 'COFINSST_QBCPROD', Det.Imposto.COFINSST.qBCProd);
      AtribuirNumero(Q, 'COFINSST_VALIQPROD', Det.Imposto.COFINSST.vAliqProd);
      AtribuirNumero(Q, 'COFINSST_VCOFINS', Det.Imposto.COFINSST.vCOFINS);
      AtribuirTexto(Q, 'COFINSST_INDSOMACOFINSST', indSomaCOFINSSTToStr(Det.Imposto.COFINSST.indSomaCOFINSST));
    end;
    if Det.Imposto.ISSQN.cListServ <> '' then
    begin
      AtribuirNumero(Q, 'ISSQN_VBC', Det.Imposto.ISSQN.vBC);
      AtribuirNumero(Q, 'ISSQN_VALIQ', Det.Imposto.ISSQN.vAliq);
      AtribuirNumero(Q, 'ISSQN_VISSQN', Det.Imposto.ISSQN.vISSQN);
      AtribuirInteiroOpcional(Q, 'ISSQN_CMUNFG', Det.Imposto.ISSQN.cMunFG);
      AtribuirTexto(Q, 'ISSQN_CLISTSERV', Det.Imposto.ISSQN.cListServ);
      AtribuirTexto(Q, 'ISSQN_CSITTRIB', ISSQNcSitTribToStr(Det.Imposto.ISSQN.cSitTrib));
      AtribuirNumero(Q, 'ISSQN_VDEDUCAO', Det.Imposto.ISSQN.vDeducao);
      AtribuirNumero(Q, 'ISSQN_VOUTRO', Det.Imposto.ISSQN.vOutro);
      AtribuirNumero(Q, 'ISSQN_VDESCINCOND', Det.Imposto.ISSQN.vDescIncond);
      AtribuirNumero(Q, 'ISSQN_VDESCCOND', Det.Imposto.ISSQN.vDescCond);
      AtribuirTexto(Q, 'ISSQN_INDISSRET', indISSRetToStr(Det.Imposto.ISSQN.indISSRet));
      AtribuirNumero(Q, 'ISSQN_VISSRET', Det.Imposto.ISSQN.vISSRet);
      AtribuirTexto(Q, 'ISSQN_INDISS', indISSToStr(Det.Imposto.ISSQN.indISS));
      AtribuirTexto(Q, 'ISSQN_CSERVICO', Det.Imposto.ISSQN.cServico);
      AtribuirInteiroOpcional(Q, 'ISSQN_CMUN', Det.Imposto.ISSQN.cMun);
      AtribuirInteiroOpcional(Q, 'ISSQN_CPAIS', Det.Imposto.ISSQN.cPais);
      AtribuirTexto(Q, 'ISSQN_NPROCESSO', Det.Imposto.ISSQN.nProcesso);
      AtribuirTexto(Q, 'ISSQN_INDINCENTIVO', indIncentivoToStr(Det.Imposto.ISSQN.indIncentivo));
    end;
    if (Det.Imposto.ICMSUFDest.vBCUFDest > 0) or (Det.Imposto.ICMSUFDest.pICMSInterPart > 0) then
    begin
      AtribuirNumero(Q, 'ICMSUFDEST_VBCUFDEST', Det.Imposto.ICMSUFDest.vBCUFDest);
      AtribuirNumero(Q, 'ICMSUFDEST_VBCFCPUFDEST', Det.Imposto.ICMSUFDest.vBCFCPUFDest);
      AtribuirNumero(Q, 'ICMSUFDEST_PFCPUFDEST', Det.Imposto.ICMSUFDest.pFCPUFDest);
      AtribuirNumero(Q, 'ICMSUFDEST_PICMSUFDEST', Det.Imposto.ICMSUFDest.pICMSUFDest);
      AtribuirNumero(Q, 'ICMSUFDEST_PICMSINTER', Det.Imposto.ICMSUFDest.pICMSInter);
      AtribuirNumero(Q, 'ICMSUFDEST_PICMSINTERPART', Det.Imposto.ICMSUFDest.pICMSInterPart);
      AtribuirNumero(Q, 'ICMSUFDEST_VFCPUFDEST', Det.Imposto.ICMSUFDest.vFCPUFDest);
      AtribuirNumero(Q, 'ICMSUFDEST_VICMSUFDEST', Det.Imposto.ICMSUFDest.vICMSUFDest);
      AtribuirNumero(Q, 'ICMSUFDEST_VICMSUFREMET', Det.Imposto.ICMSUFDest.vICMSUFRemet);
    end;
    if (Det.Imposto.ISel.vBCIS > 0) or (Det.Imposto.ISel.pIS > 0) or (Det.Imposto.ISel.uTrib <> '') then
    begin
      AtribuirTexto(Q, 'IS_CSTIS', CSTISToStr(Det.Imposto.ISel.CSTIS));
      AtribuirTexto(Q, 'IS_CCLASSTRIBIS', cClassTribISToStr(Det.Imposto.ISel.cClassTribIS));
      AtribuirNumero(Q, 'IS_VBCIS', Det.Imposto.ISel.vBCIS);
      AtribuirNumero(Q, 'IS_PIS', Det.Imposto.ISel.pIS);
      AtribuirNumero(Q, 'IS_PISESPEC', Det.Imposto.ISel.pISEspec);
      AtribuirTexto(Q, 'IS_UTRIB', Det.Imposto.ISel.uTrib);
      AtribuirNumero(Q, 'IS_QTRIB', Det.Imposto.ISel.qTrib);
      AtribuirNumero(Q, 'IS_VIS', Det.Imposto.ISel.vIS);
    end;
    if (Det.Imposto.IBSCBS.gIBSCBS.vBC > 0) or (Det.Imposto.IBSCBS.gIBSCBSMono.adRemIBS > 0) or (Det.Imposto.IBSCBS.gTransfCred.vIBS > 0) or (Det.Imposto.IBSCBS.gTransfCred.vCBS > 0) then
    begin
      AtribuirTexto(Q, 'IBSCBS_CST', CSTIBSCBSToStr(Det.Imposto.IBSCBS.CST));
      AtribuirTexto(Q, 'IBSCBS_CCLASSTRIB', cClassTribToStr(Det.Imposto.IBSCBS.cClassTrib));
      AtribuirNumero(Q, 'IBSCBS_VBC', Det.Imposto.IBSCBS.gIBSCBS.vBC);
      AtribuirNumero(Q, 'IBSUF_PIBSUF', Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.pIBSUF);
      AtribuirNumero(Q, 'IBSUF_PDIF', Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.gDif.pDif);
      AtribuirNumero(Q, 'IBSUF_VDIF', Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.gDif.vDif);
      AtribuirNumero(Q, 'IBSUF_VDEVTRIB', Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.gDevTrib.vDevTrib);
      AtribuirNumero(Q, 'IBSUF_PREDALIQ', Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.gRed.pRedAliq);
      AtribuirNumero(Q, 'IBSUF_PALIQEFET', Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.gRed.pAliqEfet);
      AtribuirNumero(Q, 'IBSUF_VIBSUF', Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.vIBSUF);
      AtribuirNumero(Q, 'IBSMUN_PIBSMUN', Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.pIBSMun);
      AtribuirNumero(Q, 'IBSMUN_PDIF', Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.gDif.pDif);
      AtribuirNumero(Q, 'IBSMUN_VDIF', Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.gDif.vDif);
      AtribuirNumero(Q, 'IBSMUN_VDEVTRIB', Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.gDevTrib.vDevTrib);
      AtribuirNumero(Q, 'IBSMUN_PREDALIQ', Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.gRed.pRedAliq);
      AtribuirNumero(Q, 'IBSMUN_PALIQEFET', Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.gRed.pAliqEfet);
      AtribuirNumero(Q, 'IBSMUN_VIBSMUN', Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.vIBSMun);
      AtribuirNumero(Q, 'CBS_PCBS', Det.Imposto.IBSCBS.gIBSCBS.gCBS.pCBS);
      AtribuirNumero(Q, 'CBS_PDIF', Det.Imposto.IBSCBS.gIBSCBS.gCBS.gDif.pDif);
      AtribuirNumero(Q, 'CBS_VDIF', Det.Imposto.IBSCBS.gIBSCBS.gCBS.gDif.vDif);
      AtribuirNumero(Q, 'CBS_VDEVTRIB', Det.Imposto.IBSCBS.gIBSCBS.gCBS.gDevTrib.vDevTrib);
      AtribuirNumero(Q, 'CBS_PREDALIQ', Det.Imposto.IBSCBS.gIBSCBS.gCBS.gRed.pRedAliq);
      AtribuirNumero(Q, 'CBS_PALIQEFET', Det.Imposto.IBSCBS.gIBSCBS.gCBS.gRed.pAliqEfet);
      AtribuirNumero(Q, 'CBS_VCBS', Det.Imposto.IBSCBS.gIBSCBS.gCBS.vCBS);
      AtribuirTexto(Q, 'TRIBREG_CSTREG', CSTIBSCBSToStr(Det.Imposto.IBSCBS.gIBSCBS.gTribRegular.CSTReg));
      AtribuirTexto(Q, 'TRIBREG_CCLASSTRIBREG', cClassTribToStr(Det.Imposto.IBSCBS.gIBSCBS.gTribRegular.cClassTribReg));
      AtribuirNumero(Q, 'TRIBREG_PALIQEFETREGIBSUF', Det.Imposto.IBSCBS.gIBSCBS.gTribRegular.pAliqEfetRegIBSUF);
      AtribuirNumero(Q, 'TRIBREG_VTRIBREGIBSUF', Det.Imposto.IBSCBS.gIBSCBS.gTribRegular.vTribRegIBSUF);
      AtribuirNumero(Q, 'TRIBREG_PALIQEFETREGIBSMUN', Det.Imposto.IBSCBS.gIBSCBS.gTribRegular.pAliqEfetRegIBSMun);
      AtribuirNumero(Q, 'TRIBREG_VTRIBREGIBSMUN', Det.Imposto.IBSCBS.gIBSCBS.gTribRegular.vTribRegIBSMun);
      AtribuirNumero(Q, 'TRIBREG_PALIQEFETREGCBS', Det.Imposto.IBSCBS.gIBSCBS.gTribRegular.pAliqEfetRegCBS);
      AtribuirNumero(Q, 'TRIBREG_VTRIBREGCBS', Det.Imposto.IBSCBS.gIBSCBS.gTribRegular.vTribRegCBS);
      AtribuirTexto(Q, 'IBSCREDPRES_CCREDPRES', cCredPresToStr(Det.Imposto.IBSCBS.gIBSCBS.gIBSCredPres.cCredPres));
      AtribuirNumero(Q, 'IBSCREDPRES_PCREDPRES', Det.Imposto.IBSCBS.gIBSCBS.gIBSCredPres.pCredPres);
      AtribuirNumero(Q, 'IBSCREDPRES_VCREDPRES', Det.Imposto.IBSCBS.gIBSCBS.gIBSCredPres.vCredPres);
      AtribuirNumero(Q, 'IBSCREDPRES_VCREDPRESCONDSUS', Det.Imposto.IBSCBS.gIBSCBS.gIBSCredPres.vCredPresCondSus);
      AtribuirTexto(Q, 'CBSCREDPRES_CCREDPRES', cCredPresToStr(Det.Imposto.IBSCBS.gIBSCBS.gCBSCredPres.cCredPres));
      AtribuirNumero(Q, 'CBSCREDPRES_PCREDPRES', Det.Imposto.IBSCBS.gIBSCBS.gCBSCredPres.pCredPres);
      AtribuirNumero(Q, 'CBSCREDPRES_VCREDPRES', Det.Imposto.IBSCBS.gIBSCBS.gCBSCredPres.vCredPres);
      AtribuirNumero(Q, 'CBSCREDPRES_VCREDPRESCONDSUS', Det.Imposto.IBSCBS.gIBSCBS.gCBSCredPres.vCredPresCondSus);
      AtribuirNumero(Q, 'TRIBCOMPRAGOV_PALIQIBSUF', Det.Imposto.IBSCBS.gIBSCBS.gTribCompraGov.pAliqIBSUF);
      AtribuirNumero(Q, 'TRIBCOMPRAGOV_VTRIBIBSUF', Det.Imposto.IBSCBS.gIBSCBS.gTribCompraGov.vTribIBSUF);
      AtribuirNumero(Q, 'TRIBCOMPRAGOV_PALIQIBSMUN', Det.Imposto.IBSCBS.gIBSCBS.gTribCompraGov.pAliqIBSMun);
      AtribuirNumero(Q, 'TRIBCOMPRAGOV_VTRIBIBSMUN', Det.Imposto.IBSCBS.gIBSCBS.gTribCompraGov.vTribIBSMun);
      AtribuirNumero(Q, 'TRIBCOMPRAGOV_PALIQCBS', Det.Imposto.IBSCBS.gIBSCBS.gTribCompraGov.pAliqCBS);
      AtribuirNumero(Q, 'TRIBCOMPRAGOV_VTRIBCBS', Det.Imposto.IBSCBS.gIBSCBS.gTribCompraGov.vTribCBS);
      AtribuirNumero(Q, 'MONO_QBCMONO', Det.Imposto.IBSCBS.gIBSCBSMono.qBCMono);
      AtribuirNumero(Q, 'MONO_ADREMIBS', Det.Imposto.IBSCBS.gIBSCBSMono.adRemIBS);
      AtribuirNumero(Q, 'MONO_ADREMCBS', Det.Imposto.IBSCBS.gIBSCBSMono.adRemCBS);
      AtribuirNumero(Q, 'MONO_VIBSMONO', Det.Imposto.IBSCBS.gIBSCBSMono.vIBSMono);
      AtribuirNumero(Q, 'MONO_VCBSMONO', Det.Imposto.IBSCBS.gIBSCBSMono.vCBSMono);
      AtribuirNumero(Q, 'MONO_QBCMONORETEN', Det.Imposto.IBSCBS.gIBSCBSMono.qBCMonoReten);
      AtribuirNumero(Q, 'MONO_ADREMIBSRETEN', Det.Imposto.IBSCBS.gIBSCBSMono.adRemIBSReten);
      AtribuirNumero(Q, 'MONO_VIBSMONORETEN', Det.Imposto.IBSCBS.gIBSCBSMono.vIBSMonoReten);
      AtribuirNumero(Q, 'MONO_ADREMCBSRETEN', Det.Imposto.IBSCBS.gIBSCBSMono.adRemCBSReten);
      AtribuirNumero(Q, 'MONO_VCBSMONORETEN', Det.Imposto.IBSCBS.gIBSCBSMono.vCBSMonoReten);
      AtribuirNumero(Q, 'MONO_QBCMONORET', Det.Imposto.IBSCBS.gIBSCBSMono.qBCMonoRet);
      AtribuirNumero(Q, 'MONO_ADREMIBSRET', Det.Imposto.IBSCBS.gIBSCBSMono.adRemIBSRet);
      AtribuirNumero(Q, 'MONO_VIBSMONORET', Det.Imposto.IBSCBS.gIBSCBSMono.vIBSMonoRet);
      AtribuirNumero(Q, 'MONO_ADREMCBSRET', Det.Imposto.IBSCBS.gIBSCBSMono.adRemCBSRet);
      AtribuirNumero(Q, 'MONO_VCBSMONORET', Det.Imposto.IBSCBS.gIBSCBSMono.vCBSMonoRet);
      AtribuirNumero(Q, 'MONO_PDIFIBS', Det.Imposto.IBSCBS.gIBSCBSMono.pDifIBS);
      AtribuirNumero(Q, 'MONO_VIBSMONODIF', Det.Imposto.IBSCBS.gIBSCBSMono.vIBSMonoDif);
      AtribuirNumero(Q, 'MONO_PDIFCBS', Det.Imposto.IBSCBS.gIBSCBSMono.pDifCBS);
      AtribuirNumero(Q, 'MONO_VCBSMONODIF', Det.Imposto.IBSCBS.gIBSCBSMono.vCBSMonoDif);
      AtribuirNumero(Q, 'MONO_VTOTIBSMONOITEM', Det.Imposto.IBSCBS.gIBSCBSMono.vTotIBSMonoItem);
      AtribuirNumero(Q, 'MONO_VTOTCBSMONOITEM', Det.Imposto.IBSCBS.gIBSCBSMono.vTotCBSMonoItem);
      AtribuirNumero(Q, 'TRANSFCRED_VIBS', Det.Imposto.IBSCBS.gTransfCred.vIBS);
      AtribuirNumero(Q, 'TRANSFCRED_VCBS', Det.Imposto.IBSCBS.gTransfCred.vCBS);
      AtribuirTexto(Q, 'CREDPRESIBSZFM_TPCREDPRESIBSZFM', TpCredPresIBSZFMToStr(Det.Imposto.IBSCBS.gCredPresIBSZFM.tpCredPresIBSZFM));
      AtribuirNumero(Q, 'CREDPRESIBSZFM_VCREDPRESIBSZFM', Det.Imposto.IBSCBS.gCredPresIBSZFM.vCredPresIBSZFM);
    end;
    AtribuirNumero(Q, 'PDEVOL', Det.pDevol);
    AtribuirNumero(Q, 'VIPIDEVOL', Det.vIPIDevol);
    AtribuirTexto(Q, 'INFADPROD', Det.infAdProd);
    AtribuirTexto(Q, 'OBSCONT_XCAMPO', Det.obsCont.xCampo);
    AtribuirTexto(Q, 'OBSCONT_XTEXTO', Det.obsCont.xTexto);
    AtribuirTexto(Q, 'OBSFISCO_XCAMPO', Det.obsFisco.xCampo);
    AtribuirTexto(Q, 'OBSFISCO_XTEXTO', Det.obsFisco.xTexto);
    AtribuirNumero(Q, 'VITEM', Det.vItem);
    if Det.DFeReferenciado.chaveAcesso <> '' then
    begin
      AtribuirTexto(Q, 'DFEREF_CHAVEACESSO', Det.DFeReferenciado.chaveAcesso);
      AtribuirInteiroOpcional(Q, 'DFEREF_NITEM', Det.DFeReferenciado.nItem);
    end;
    Q.ExecSQL;
  end;
end;

procedure TProcessadorNFe.GravarFatura(NFe: TNFe; const Chave: string);
var
  Q: TZQuery;
begin
  if (NFe.Cobr.Fat.nFat = '') and (NFe.Cobr.Fat.vOrig = 0) and (NFe.Cobr.Fat.vLiq = 0) then
    Exit;
  Q := dmdNFe.cmdInsNFeFat;
  LimparParametros(Q);
  AtribuirTexto(Q, 'CHNFE', Chave);
  AtribuirTexto(Q, 'NFAT', NFe.Cobr.Fat.nFat);
  AtribuirNumero(Q, 'VORIG', NFe.Cobr.Fat.vOrig);
  AtribuirNumero(Q, 'VDESC', NFe.Cobr.Fat.vDesc);
  AtribuirNumero(Q, 'VLIQ', NFe.Cobr.Fat.vLiq);
  Q.ExecSQL;
end;

procedure TProcessadorNFe.GravarDuplicatas(NFe: TNFe; const Chave: string);
var
  Q: TZQuery;
  I: integer;
  Dup: TDupCollectionItem;
begin
  Q := dmdNFe.cmdInsNFeDup;
  for I := 0 to NFe.Cobr.Dup.Count - 1 do
  begin
    Dup := NFe.Cobr.Dup[I];
    LimparParametros(Q);
    AtribuirTexto(Q, 'CHNFE', Chave);
    AtribuirInteiro(Q, 'SEQ', I + 1);
    AtribuirTexto(Q, 'NDUP', Dup.nDup);
    AtribuirData(Q, 'DVENC', Dup.dVenc);
    AtribuirNumero(Q, 'VDUP', Dup.vDup);
    Q.ExecSQL;
  end;
end;

procedure TProcessadorNFe.GravarVolumes(NFe: TNFe; const Chave: string);
var
  Q: TZQuery;
  I: integer;
  Vol: TVolCollectionItem;
begin
  Q := dmdNFe.cmdInsNFeVol;
  for I := 0 to NFe.Transp.Vol.Count - 1 do
  begin
    Vol := NFe.Transp.Vol[I];
    LimparParametros(Q);
    AtribuirTexto(Q, 'CHNFE', Chave);
    AtribuirInteiro(Q, 'SEQ', I + 1);
    AtribuirInteiro(Q, 'QVOL', Vol.qVol);
    AtribuirTexto(Q, 'ESP', Vol.esp);
    AtribuirTexto(Q, 'MARCA', Vol.marca);
    AtribuirTexto(Q, 'NVOL', Vol.nVol);
    AtribuirNumero(Q, 'PESOL', Vol.pesoL);
    AtribuirNumero(Q, 'PESOB', Vol.pesoB);
    Q.ExecSQL;
  end;
end;

procedure TProcessadorNFe.GravarPagamentos(NFe: TNFe; const Chave: string);
var
  Q: TZQuery;
  I: integer;
  Pag: TpagCollectionItem;
begin
  Q := dmdNFe.cmdInsNFePgt;
  for I := 0 to NFe.pag.Count - 1 do
  begin
    Pag := NFe.pag[I];
    LimparParametros(Q);
    AtribuirTexto(Q, 'CHNFE', Chave);
    AtribuirInteiro(Q, 'SEQ', I + 1);
    AtribuirTexto(Q, 'INDPAG', IndpagToStrEX(Pag.indPag));
    AtribuirTexto(Q, 'TPAG', FormaPagamentoToStr(Pag.tPag));
    AtribuirTexto(Q, 'XPAG', Pag.xPag);
    AtribuirNumero(Q, 'VPAG', Pag.vPag);
    if Pag.tpIntegra <> tiNaoInformado then
    begin
      AtribuirTexto(Q, 'TPINTEGRA', tpIntegraToStr(Pag.tpIntegra));
      AtribuirTexto(Q, 'CNPJ', Pag.CNPJ);
      AtribuirTexto(Q, 'TBAND', BandeiraCartaoToStr(Pag.tBand));
      AtribuirTexto(Q, 'CAUT', Pag.cAut);
    end;
    AtribuirData(Q, 'DPAG', Pag.dPag);
    AtribuirTexto(Q, 'CNPJPAG', Pag.CNPJPag);
    AtribuirTexto(Q, 'UFPAG', Pag.UFPag);
    AtribuirTexto(Q, 'CNPJRECEB', Pag.CNPJReceb);
    AtribuirTexto(Q, 'IDTERMPAG', Pag.idTermPag);
    Q.ExecSQL;
  end;
end;

end.
