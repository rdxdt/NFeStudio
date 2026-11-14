unit tstprocessadornfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, ZConnection, ZDataset, ACBrNFe,
  uprocessadornfe;

type

  { TProcessadorNFeMock }

  // substitui o webservice da SEFAZ: carrega ArquivoRetorno como se fosse a nota atualizada pela consulta
  TProcessadorNFeMock = class(TProcessadorNFe)
  private
    FConsultas: integer;
    FArquivoRetorno: string;
  protected
    procedure ConsultarSEFAZ; override;
  public
    property Consultas: integer read FConsultas;
    property ArquivoRetorno: string read FArquivoRetorno write FArquivoRetorno;
  end;

  { TTesteProcessadorNFe }

  TTesteProcessadorNFe = class(TTestCase)
  private
    FPasta: string;
    FConexao: TZConnection;
    FACBrNFe: TACBrNFe;
    FProcessador: TProcessadorNFe;
    procedure GerarNFeSimplesNacional(const Arquivo: string; RemoverId: boolean = False);
    procedure GravarArquivo(const Arquivo, Conteudo: string);
    procedure MontarPastaNotas;
    function Consultar(const SQL: string): string;
    function Contar(const Tabela: string): integer;
    procedure ImportarSemACBrNFe;
    procedure ImportarDiretorioInexistente;
    procedure ImportarNFeSemProtocolo;
    function CriarProcessadorMock: TProcessadorNFeMock;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestImportacaoRecursiva;
    procedure TestArquivosIgnoradosNoLog;
    procedure TestCabecalhoProcNFe;
    procedure TestDetalhesProcNFe;
    procedure TestSimplesNacionalComIBSCBS;
    procedure TestPagamentoCartao;
    procedure TestReimportacaoSubstituiNota;
    procedure TestXMLOriginalGravado;
    procedure TestSemACBrNFeGeraExcecao;
    procedure TestDiretorioInexistenteGeraExcecao;
    procedure TestAtualizarProtocoloConsultaSEFAZ;
    procedure TestAtualizarProtocoloNotaJaProtocolada;
    procedure TestAtualizarProtocoloNotaNaoAutorizada;
    procedure TestAtualizarProtocoloChaveInexistente;
  end;

implementation

uses
  FileUtil, ACBrNFe.Classes, pcnConversao, pcnConversaoNFe, ACBrDFe.Conversao, udmdnfe;

const
  CHAVE_PROCNFE = '35150905481336000137550010000111291000111298';
  ARQUIVO_PROCNFE = CHAVE_PROCNFE + '-nfe.xml';
  SQL_PROT_NPROT = 'SELECT PROT_NPROT FROM NFE_CAB WHERE CHNFE = ''' + CHAVE_PROCNFE + '''';

function PastaFixtures: string;
begin
  // o executável é gerado em bin/linux64/tests e as fixtures ficam em tests/fixtures
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '../../../tests/fixtures') + PathDelim;
end;

{ TProcessadorNFeMock }

procedure TProcessadorNFeMock.ConsultarSEFAZ;
begin
  Inc(FConsultas);
  if FArquivoRetorno = '' then
    Exit;
  ACBrNFe.NotasFiscais.Clear;
  ACBrNFe.NotasFiscais.LoadFromFile(FArquivoRetorno);
end;

{ TTesteProcessadorNFe }

procedure TTesteProcessadorNFe.SetUp;
var
  I: integer;
begin
  FPasta := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'nfestudio-teste-' +
    IntToStr(GetProcessID) + PathDelim;
  DeleteDirectory(FPasta, False);
  ForceDirectories(FPasta + 'notas');

  FConexao := TZConnection.Create(nil);
  FConexao.Protocol := 'sqlite';
  FConexao.Database := FPasta + 'teste.sqlite3';
  FConexao.Connect;

  // o datamodule aponta para frmMain.ZConnection1, que não existe no teste
  dmdNFe := TdmdNFe.Create(nil);
  for I := 0 to dmdNFe.ComponentCount - 1 do
    if dmdNFe.Components[I] is TZQuery then
      TZQuery(dmdNFe.Components[I]).Connection := FConexao;
  dmdNFe.sqlCreateTables.Connection := FConexao;
  dmdNFe.CriarTabelas;

  FACBrNFe := TACBrNFe.Create(nil);
  FProcessador := TProcessadorNFe.Create(nil);
  FProcessador.ACBrNFe := FACBrNFe;
end;

procedure TTesteProcessadorNFe.TearDown;
begin
  FProcessador.Free;
  FACBrNFe.Free;
  FreeAndNil(dmdNFe);
  FConexao.Free;
  DeleteDirectory(FPasta, False);
end;

procedure TTesteProcessadorNFe.GravarArquivo(const Arquivo, Conteudo: string);
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  try
    Lista.Text := Conteudo;
    Lista.SaveToFile(Arquivo);
  finally
    Lista.Free;
  end;
end;

procedure TTesteProcessadorNFe.GerarNFeSimplesNacional(const Arquivo: string; RemoverId: boolean);
var
  NFe: TNFe;
  Det: TDetCollectionItem;
  Pag: TpagCollectionItem;
  XML: string;
begin
  FACBrNFe.NotasFiscais.Clear;
  NFe := FACBrNFe.NotasFiscais.Add.NFe;
  NFe.infNFe.Versao := 4;
  NFe.Ide.cUF := 35;
  NFe.Ide.cNF := 12345678;
  NFe.Ide.natOp := 'VENDA';
  NFe.Ide.modelo := 55;
  NFe.Ide.serie := 1;
  NFe.Ide.nNF := 10;
  NFe.Ide.dEmi := EncodeDate(2026, 11, 5) + EncodeTime(14, 30, 0, 0);
  NFe.Ide.tpNF := tnSaida;
  NFe.Ide.idDest := doInterna;
  NFe.Ide.cMunFG := 3550308;
  NFe.Ide.tpImp := tiRetrato;
  NFe.Ide.tpEmis := teNormal;
  NFe.Ide.tpAmb := taHomologacao;
  NFe.Ide.finNFe := fnNormal;
  NFe.Ide.indFinal := cfConsumidorFinal;
  NFe.Ide.indPres := pcPresencial;
  NFe.Ide.procEmi := peAplicativoContribuinte;
  NFe.Ide.verProc := 'teste';

  NFe.Emit.CNPJCPF := '12345678000195';
  NFe.Emit.xNome := 'Emitente Teste';
  NFe.Emit.IE := '111111111111';
  NFe.Emit.CRT := crtSimplesNacional;
  NFe.Emit.EnderEmit.xLgr := 'Rua A';
  NFe.Emit.EnderEmit.nro := '1';
  NFe.Emit.EnderEmit.xBairro := 'Centro';
  NFe.Emit.EnderEmit.cMun := 3550308;
  NFe.Emit.EnderEmit.xMun := 'São Paulo';
  NFe.Emit.EnderEmit.UF := 'SP';
  NFe.Emit.EnderEmit.CEP := 1310100;

  NFe.Dest.CNPJCPF := '01234567890';
  NFe.Dest.xNome := 'Consumidor Teste';
  NFe.Dest.indIEDest := inNaoContribuinte;
  NFe.Dest.EnderDest.xLgr := 'Rua B';
  NFe.Dest.EnderDest.nro := '2';
  NFe.Dest.EnderDest.xBairro := 'Centro';
  NFe.Dest.EnderDest.cMun := 3550308;
  NFe.Dest.EnderDest.xMun := 'São Paulo';
  NFe.Dest.EnderDest.UF := 'SP';

  Det := NFe.Det.New;
  Det.Prod.nItem := 1;
  Det.Prod.cProd := 'P1';
  Det.Prod.xProd := 'Produto 1';
  Det.Prod.NCM := '61091000';
  Det.Prod.CFOP := '5102';
  Det.Prod.uCom := 'UN';
  Det.Prod.qCom := 2;
  Det.Prod.vUnCom := 10.5;
  Det.Prod.vProd := 21;
  Det.Prod.uTrib := 'UN';
  Det.Prod.qTrib := 2;
  Det.Prod.vUnTrib := 10.5;
  Det.Imposto.ICMS.orig := oeNacional;
  Det.Imposto.ICMS.CSOSN := csosn102;
  Det.Imposto.PIS.CST := pis07;
  Det.Imposto.COFINS.CST := cof07;
  Det.Imposto.IBSCBS.CST := cst000;
  Det.Imposto.IBSCBS.cClassTrib := ct000001;
  Det.Imposto.IBSCBS.gIBSCBS.vBC := 21;
  Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.pIBSUF := 0.1;
  Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.vIBSUF := 0.02;
  Det.Imposto.IBSCBS.gIBSCBS.gCBS.pCBS := 0.9;
  Det.Imposto.IBSCBS.gIBSCBS.gCBS.vCBS := 0.19;

  Det := NFe.Det.New;
  Det.Prod.nItem := 2;
  Det.Prod.cProd := 'P2';
  Det.Prod.xProd := 'Produto 2';
  Det.Prod.NCM := '61091000';
  Det.Prod.CFOP := '5102';
  Det.Prod.uCom := 'UN';
  Det.Prod.qCom := 1;
  Det.Prod.vUnCom := 10.5;
  Det.Prod.vProd := 10.5;
  Det.Prod.uTrib := 'UN';
  Det.Prod.qTrib := 1;
  Det.Prod.vUnTrib := 10.5;
  Det.Imposto.ICMS.orig := oeNacional;
  Det.Imposto.ICMS.CSOSN := csosn102;
  Det.Imposto.PIS.CST := pis07;
  Det.Imposto.COFINS.CST := cof07;

  NFe.Total.ICMSTot.vProd := 31.5;
  NFe.Total.ICMSTot.vNF := 31.5;
  NFe.Transp.modFrete := mfSemFrete;

  Pag := NFe.pag.New;
  Pag.tPag := fpCartaoCredito;
  Pag.vPag := 31.5;
  Pag.tpIntegra := tiPagNaoIntegrado;
  Pag.tBand := bcMasterCard;

  XML := FACBrNFe.NotasFiscais[0].GerarXML;
  if RemoverId then
    XML := StringReplace(XML, ' Id="', ' Removido="', []);
  GravarArquivo(Arquivo, XML);
  FACBrNFe.NotasFiscais.Clear;
end;

procedure TTesteProcessadorNFe.MontarPastaNotas;
var
  Notas: string;
begin
  Notas := FPasta + 'notas' + PathDelim;
  ForceDirectories(Notas + 'sub' + PathDelim + 'sub2');
  CopyFile(PastaFixtures + ARQUIVO_PROCNFE, Notas + ARQUIVO_PROCNFE);
  // extensão em maiúsculas deve ser reconhecida
  GerarNFeSimplesNacional(Notas + 'sub' + PathDelim + 'nfe-simples.XML');
  GerarNFeSimplesNacional(Notas + 'sub' + PathDelim + 'sub2' + PathDelim + 'sem-id.xml', True);
  GravarArquivo(Notas + 'sub' + PathDelim + 'sub2' + PathDelim + 'evento.xml', '<evento/>');
  GravarArquivo(Notas + 'leia-me.txt', 'não é xml');
end;

function TTesteProcessadorNFe.Consultar(const SQL: string): string;
var
  Q: TZQuery;
begin
  Q := TZQuery.Create(nil);
  try
    Q.Connection := FConexao;
    Q.SQL.Text := SQL;
    Q.Open;
    if Q.IsEmpty or Q.Fields[0].IsNull then
      Result := '<null>'
    else
      Result := Q.Fields[0].AsString;
  finally
    Q.Free;
  end;
end;

function TTesteProcessadorNFe.Contar(const Tabela: string): integer;
begin
  Result := StrToInt(Consultar('SELECT COUNT(*) FROM ' + Tabela));
end;

procedure TTesteProcessadorNFe.TestImportacaoRecursiva;
begin
  MontarPastaNotas;
  AssertEquals('notas importadas', 2, FProcessador.Importar(FPasta + 'notas'));
  AssertEquals('NFE_CAB', 2, Contar('NFE_CAB'));
end;

procedure TTesteProcessadorNFe.TestArquivosIgnoradosNoLog;
begin
  MontarPastaNotas;
  FProcessador.Importar(FPasta + 'notas');
  // sem-id.xml e evento.xml; o .txt não é considerado
  AssertEquals('linhas de log: ' + FProcessador.Log.Text, 2, FProcessador.Log.Count);
  AssertTrue(Pos('sem-id.xml', FProcessador.Log.Text) > 0);
  AssertTrue(Pos('evento.xml', FProcessador.Log.Text) > 0);
end;

procedure TTesteProcessadorNFe.TestCabecalhoProcNFe;
const
  WHERE_CHAVE = ' FROM NFE_CAB WHERE CHNFE = ''' + CHAVE_PROCNFE + '''';
begin
  MontarPastaNotas;
  FProcessador.Importar(FPasta + 'notas');
  AssertEquals('EMIT_CNPJCPF', '05481336000137', Consultar('SELECT EMIT_CNPJCPF' + WHERE_CHAVE));
  AssertEquals('EMIT_CRT', '3', Consultar('SELECT EMIT_CRT' + WHERE_CHAVE));
  AssertEquals('IDE_NNF', '11129', Consultar('SELECT IDE_NNF' + WHERE_CHAVE));
  AssertEquals('IDE_DHEMI', '2015-09-23', Consultar('SELECT DATE(IDE_DHEMI)' + WHERE_CHAVE));
  AssertEquals('TOT_VNF', '100.00', Consultar('SELECT PRINTF(''%.2f'', TOT_VNF)' + WHERE_CHAVE));
  AssertEquals('PROT_NPROT', '135150003833609', Consultar('SELECT PROT_NPROT' + WHERE_CHAVE));
  AssertEquals('PROT_CSTAT', '100', Consultar('SELECT PROT_CSTAT' + WHERE_CHAVE));
  AssertEquals('TRANSP_MODFRETE', '0', Consultar('SELECT TRANSP_MODFRETE' + WHERE_CHAVE));
  AssertEquals('AVULSA_CNPJ', '<null>', Consultar('SELECT AVULSA_CNPJ' + WHERE_CHAVE));
end;

procedure TTesteProcessadorNFe.TestDetalhesProcNFe;
const
  WHERE_CHAVE = ' WHERE CHNFE = ''' + CHAVE_PROCNFE + '''';
begin
  MontarPastaNotas;
  FProcessador.Importar(FPasta + 'notas');
  AssertEquals('NFE_DET', 1, StrToInt(Consultar('SELECT COUNT(*) FROM NFE_DET' + WHERE_CHAVE)));
  AssertEquals('ICMS_CST', '00', Consultar('SELECT ICMS_CST FROM NFE_DET' + WHERE_CHAVE));
  AssertEquals('NFE_DUP', 2, StrToInt(Consultar('SELECT COUNT(*) FROM NFE_DUP' + WHERE_CHAVE)));
  AssertEquals('NDUP', '1235', Consultar('SELECT NDUP FROM NFE_DUP' + WHERE_CHAVE + ' AND SEQ = 2'));
  AssertEquals('NFE_VOL', 1, StrToInt(Consultar('SELECT COUNT(*) FROM NFE_VOL' + WHERE_CHAVE)));
  AssertEquals('QVOL', '1', Consultar('SELECT QVOL FROM NFE_VOL' + WHERE_CHAVE));
end;

procedure TTesteProcessadorNFe.TestSimplesNacionalComIBSCBS;
const
  WHERE_ITEM = ' FROM NFE_DET WHERE CHNFE <> ''' + CHAVE_PROCNFE + ''' AND NITEM = ';
begin
  MontarPastaNotas;
  FProcessador.Importar(FPasta + 'notas');
  AssertEquals('itens', 2, StrToInt(Consultar(
    'SELECT COUNT(*) FROM NFE_DET WHERE CHNFE <> ''' + CHAVE_PROCNFE + '''')));
  AssertEquals('ICMS_CSOSN', '102', Consultar('SELECT ICMS_CSOSN' + WHERE_ITEM + '1'));
  AssertEquals('ICMS_CST', '<null>', Consultar('SELECT ICMS_CST' + WHERE_ITEM + '1'));
  AssertEquals('IPI_CST', '<null>', Consultar('SELECT IPI_CST' + WHERE_ITEM + '1'));
  AssertEquals('IBSCBS_CST', '000', Consultar('SELECT IBSCBS_CST' + WHERE_ITEM + '1'));
  AssertEquals('IBSUF_VIBSUF', '0.02', Consultar('SELECT PRINTF(''%.2f'', IBSUF_VIBSUF)' + WHERE_ITEM + '1'));
  AssertEquals('IBSCBS_CST item 2', '<null>', Consultar('SELECT IBSCBS_CST' + WHERE_ITEM + '2'));
  AssertEquals('DEST_CNPJCPF', '01234567890',
    Consultar('SELECT DEST_CNPJCPF FROM NFE_CAB WHERE CHNFE <> ''' + CHAVE_PROCNFE + ''''));
  AssertEquals('EMIT_CEP', '1310100',
    Consultar('SELECT EMIT_CEP FROM NFE_CAB WHERE CHNFE <> ''' + CHAVE_PROCNFE + ''''));
end;

procedure TTesteProcessadorNFe.TestPagamentoCartao;
const
  WHERE_NOTA = ' FROM NFE_PAG WHERE CHNFE <> ''' + CHAVE_PROCNFE + '''';
begin
  MontarPastaNotas;
  FProcessador.Importar(FPasta + 'notas');
  AssertEquals('TPAG', '03', Consultar('SELECT TPAG' + WHERE_NOTA));
  AssertEquals('TPINTEGRA', '2', Consultar('SELECT TPINTEGRA' + WHERE_NOTA));
  AssertEquals('TBAND', '02', Consultar('SELECT TBAND' + WHERE_NOTA));
end;

procedure TTesteProcessadorNFe.TestReimportacaoSubstituiNota;
var
  Itens: integer;
begin
  MontarPastaNotas;
  FProcessador.Importar(FPasta + 'notas');
  Itens := Contar('NFE_DET');
  AssertEquals('reimportação', 2, FProcessador.Importar(FPasta + 'notas'));
  AssertEquals('NFE_CAB', 2, Contar('NFE_CAB'));
  AssertEquals('NFE_DET', Itens, Contar('NFE_DET'));
  AssertEquals('NFE_DUP', 2, Contar('NFE_DUP'));
end;

procedure TTesteProcessadorNFe.TestXMLOriginalGravado;
var
  XML: string;
begin
  MontarPastaNotas;
  FProcessador.Importar(FPasta + 'notas');
  XML := dmdNFe.ObterXMLNFe(CHAVE_PROCNFE);
  AssertTrue('XML com protocolo', Pos('<nfeProc', XML) > 0);
  // o XML gravado deve ser suficiente para recarregar a nota (reimpressão da DANFE)
  FACBrNFe.NotasFiscais.Clear;
  FACBrNFe.NotasFiscais.LoadFromString(XML);
  AssertEquals('notas carregadas', 1, FACBrNFe.NotasFiscais.Count);
  AssertEquals('chave', 'NFe' + CHAVE_PROCNFE, FACBrNFe.NotasFiscais[0].NFe.infNFe.ID);
  AssertTrue('protocolo', FACBrNFe.NotasFiscais[0].NFe.procNFe.nProt <> '');
end;

procedure TTesteProcessadorNFe.ImportarSemACBrNFe;
begin
  FProcessador.ACBrNFe := nil;
  FProcessador.Importar(FPasta + 'notas');
end;

procedure TTesteProcessadorNFe.ImportarDiretorioInexistente;
begin
  FProcessador.Importar(FPasta + 'inexistente');
end;

procedure TTesteProcessadorNFe.TestSemACBrNFeGeraExcecao;
begin
  AssertException(Exception, @ImportarSemACBrNFe);
end;

procedure TTesteProcessadorNFe.TestDiretorioInexistenteGeraExcecao;
begin
  AssertException(Exception, @ImportarDiretorioInexistente);
end;

procedure TTesteProcessadorNFe.ImportarNFeSemProtocolo;
var
  Lista: TStringList;
  XML: string;
  Inicio: integer;
begin
  // mesma nota da fixture, mas somente assinada (sem nfeProc/protNFe)
  Lista := TStringList.Create;
  try
    Lista.LoadFromFile(PastaFixtures + ARQUIVO_PROCNFE);
    XML := Lista.Text;
  finally
    Lista.Free;
  end;
  Inicio := Pos('<NFe ', XML);
  XML := '<?xml version="1.0" encoding="UTF-8"?>' +
    Copy(XML, Inicio, Pos('</NFe>', XML) + Length('</NFe>') - Inicio);
  GravarArquivo(FPasta + 'notas' + PathDelim + CHAVE_PROCNFE + '.xml', XML);
  FProcessador.Importar(FPasta + 'notas');
end;

function TTesteProcessadorNFe.CriarProcessadorMock: TProcessadorNFeMock;
begin
  Result := TProcessadorNFeMock.Create(nil);
  Result.ACBrNFe := FACBrNFe;
end;

procedure TTesteProcessadorNFe.TestAtualizarProtocoloConsultaSEFAZ;
var
  Mock: TProcessadorNFeMock;
  Itens: integer;
begin
  ImportarNFeSemProtocolo;
  AssertEquals('sem protocolo antes', '<null>', Consultar(SQL_PROT_NPROT));
  Itens := Contar('NFE_DET');
  Mock := CriarProcessadorMock;
  try
    Mock.ArquivoRetorno := PastaFixtures + ARQUIVO_PROCNFE;
    AssertTrue('atualizada', Mock.AtualizarProtocolo(CHAVE_PROCNFE));
    AssertEquals('consultas', 1, Mock.Consultas);
  finally
    Mock.Free;
  end;
  AssertTrue('XML com protocolo', Pos('<nfeProc', dmdNFe.ObterXMLNFe(CHAVE_PROCNFE)) > 0);
  AssertEquals('PROT_NPROT', '135150003833609', Consultar(SQL_PROT_NPROT));
  AssertEquals('NFE_CAB', 1, Contar('NFE_CAB'));
  AssertEquals('NFE_DET', Itens, Contar('NFE_DET'));
  AssertEquals('NotasFiscais limpo', 0, FACBrNFe.NotasFiscais.Count);
end;

procedure TTesteProcessadorNFe.TestAtualizarProtocoloNotaJaProtocolada;
var
  Mock: TProcessadorNFeMock;
begin
  CopyFile(PastaFixtures + ARQUIVO_PROCNFE, FPasta + 'notas' + PathDelim + ARQUIVO_PROCNFE);
  FProcessador.Importar(FPasta + 'notas');
  Mock := CriarProcessadorMock;
  try
    AssertFalse('nada a atualizar', Mock.AtualizarProtocolo(CHAVE_PROCNFE));
    AssertEquals('SEFAZ não consultada', 0, Mock.Consultas);
  finally
    Mock.Free;
  end;
end;

procedure TTesteProcessadorNFe.TestAtualizarProtocoloNotaNaoAutorizada;
var
  Mock: TProcessadorNFeMock;
begin
  ImportarNFeSemProtocolo;
  Mock := CriarProcessadorMock;
  try
    // ArquivoRetorno vazio: a SEFAZ não devolve protocolo (ex.: nota não consta na base)
    AssertFalse('não atualizada', Mock.AtualizarProtocolo(CHAVE_PROCNFE));
    AssertEquals('consultas', 1, Mock.Consultas);
  finally
    Mock.Free;
  end;
  AssertEquals('XML mantido', 0, Pos('<nfeProc', dmdNFe.ObterXMLNFe(CHAVE_PROCNFE)));
  AssertEquals('PROT_NPROT', '<null>', Consultar(SQL_PROT_NPROT));
end;

procedure TTesteProcessadorNFe.TestAtualizarProtocoloChaveInexistente;
var
  Mock: TProcessadorNFeMock;
begin
  Mock := CriarProcessadorMock;
  try
    AssertFalse('sem nota', Mock.AtualizarProtocolo(CHAVE_PROCNFE));
    AssertEquals('SEFAZ não consultada', 0, Mock.Consultas);
  finally
    Mock.Free;
  end;
end;

initialization
  RegisterTest(TTesteProcessadorNFe);

end.
