unit tstdmdnfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, ZConnection, ZDataset;

type

  { TTesteDmdNFe }

  TTesteDmdNFe = class(TTestCase)
  private
    FPasta: string;
    FConexao: TZConnection;
    procedure InserirNFe(const Chave: string; DataEmissao: TDateTime);
    procedure InserirNotasNovembro;
    procedure InserirNFeTotais(const Chave: string; DataEmissao: TDateTime; Valor: double;
      const Quantidades: array of double);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestFiltroIgnoraHoraDosParametros;
    procedure TestFiltroPeriodo;
    procedure TestPeriodoTabelaVazia;
    procedure TestPeriodoMenorEMaiorData;
    procedure TestXMLNFeInexistente;
    procedure TestTotaisSinteticoPorDia;
    procedure TestTotaisSinteticoSemFiltro;
  end;

implementation

uses
  FileUtil, DateUtils, udmdnfe;

{ TTesteDmdNFe }

procedure TTesteDmdNFe.SetUp;
var
  I: integer;
begin
  FPasta := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'nfestudio-teste-dmd-' +
    IntToStr(GetProcessID) + PathDelim;
  DeleteDirectory(FPasta, False);
  ForceDirectories(FPasta);

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
end;

procedure TTesteDmdNFe.TearDown;
begin
  FreeAndNil(dmdNFe);
  FConexao.Free;
  DeleteDirectory(FPasta, False);
end;

procedure TTesteDmdNFe.InserirNFe(const Chave: string; DataEmissao: TDateTime);
var
  Q: TZQuery;
begin
  // grava pelo parâmetro AsDateTime, como o TProcessadorNFe, para manter o mesmo formato no banco
  Q := TZQuery.Create(nil);
  try
    Q.Connection := FConexao;
    Q.SQL.Text := 'INSERT INTO NFE_CAB (CHNFE, IDE_DHEMI) VALUES (:CHNFE, :IDE_DHEMI)';
    Q.ParamByName('CHNFE').AsString := Chave;
    Q.ParamByName('IDE_DHEMI').AsDateTime := DataEmissao;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TTesteDmdNFe.InserirNotasNovembro;
begin
  InserirNFe('A', EncodeDateTime(2026, 11, 4, 23, 59, 59, 0));
  InserirNFe('B', EncodeDateTime(2026, 11, 5, 0, 0, 0, 0));
  InserirNFe('C', EncodeDateTime(2026, 11, 5, 23, 59, 59, 0));
  InserirNFe('D', EncodeDateTime(2026, 11, 6, 10, 0, 0, 0));
end;

procedure TTesteDmdNFe.InserirNFeTotais(const Chave: string; DataEmissao: TDateTime; Valor: double;
  const Quantidades: array of double);
var
  Q: TZQuery;
  I: integer;
begin
  Q := TZQuery.Create(nil);
  try
    Q.Connection := FConexao;
    // cada total recebe Valor + posição da coluna, para detectar colunas trocadas na soma
    Q.SQL.Text := 'INSERT INTO NFE_CAB (CHNFE, IDE_DHEMI, TOT_VNF, TOT_VICMS, TOT_VPIS, TOT_VCOFINS, ' +
      'TOT_VIPI, TOT_VII, ISTOT_VIS, CBSTOT_VCBS, IBSMUNTOT_VIBSMUN, IBSUFTOT_VIBSUF) ' +
      'VALUES (:CHNFE, :IDE_DHEMI, :V0, :V1, :V2, :V3, :V4, :V5, :V6, :V7, :V8, :V9)';
    Q.ParamByName('CHNFE').AsString := Chave;
    Q.ParamByName('IDE_DHEMI').AsDateTime := DataEmissao;
    for I := 0 to 9 do
      Q.ParamByName('V' + IntToStr(I)).AsFloat := Valor + I;
    Q.ExecSQL;
    Q.SQL.Text := 'INSERT INTO NFE_DET (CHNFE, NITEM, QCOM) VALUES (:CHNFE, :NITEM, :QCOM)';
    for I := 0 to High(Quantidades) do
    begin
      Q.ParamByName('CHNFE').AsString := Chave;
      Q.ParamByName('NITEM').AsInteger := I + 1;
      Q.ParamByName('QCOM').AsFloat := Quantidades[I];
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure TTesteDmdNFe.TestFiltroIgnoraHoraDosParametros;
begin
  InserirNotasNovembro;
  // horas "invertidas" no mesmo dia: devem ser ignoradas e o dia 05 incluído por inteiro
  dmdNFe.FiltrarNFeCab(EncodeDateTime(2026, 11, 5, 15, 0, 0, 0), EncodeDateTime(2026, 11, 5, 8, 0, 0, 0));
  AssertEquals('notas do dia 05', 2, dmdNFe.qryNFeCab.RecordCount);
  AssertEquals('primeira', 'B', dmdNFe.qryNFeCab.FieldByName('CHNFE').AsString);
  dmdNFe.qryNFeCab.Last;
  AssertEquals('última', 'C', dmdNFe.qryNFeCab.FieldByName('CHNFE').AsString);
end;

procedure TTesteDmdNFe.TestFiltroPeriodo;
begin
  InserirNotasNovembro;
  dmdNFe.FiltrarNFeCab(EncodeDate(2026, 11, 4), EncodeDate(2026, 11, 6));
  AssertEquals('período completo', 4, dmdNFe.qryNFeCab.RecordCount);
  dmdNFe.FiltrarNFeCab(EncodeDate(2026, 11, 6), EncodeDate(2026, 11, 30));
  AssertEquals('a partir do dia 06', 1, dmdNFe.qryNFeCab.RecordCount);
end;

procedure TTesteDmdNFe.TestPeriodoTabelaVazia;
var
  DataInicial, DataFinal: TDateTime;
begin
  AssertFalse('tabela vazia', dmdNFe.ObterPeriodoNFeCab(DataInicial, DataFinal));
end;

procedure TTesteDmdNFe.TestPeriodoMenorEMaiorData;
var
  DataInicial, DataFinal: TDateTime;
begin
  InserirNotasNovembro;
  AssertTrue('período encontrado', dmdNFe.ObterPeriodoNFeCab(DataInicial, DataFinal));
  // somente a data é retornada, sem a hora
  AssertEquals('menor data', EncodeDate(2026, 11, 4), DataInicial);
  AssertEquals('maior data', EncodeDate(2026, 11, 6), DataFinal);
end;

procedure TTesteDmdNFe.TestXMLNFeInexistente;
begin
  InserirNotasNovembro;
  AssertEquals('sem XML gravado', '', dmdNFe.ObterXMLNFe('A'));
  AssertEquals('chave inexistente', '', dmdNFe.ObterXMLNFe('Z'));
end;

procedure TTesteDmdNFe.TestTotaisSinteticoPorDia;
const
  CAMPOS: array[0..9] of string = ('TOT_VNF', 'TOT_VICMS', 'TOT_VPIS', 'TOT_VCOFINS', 'TOT_VIPI',
    'TOT_VII', 'TOT_VIS', 'TOT_VCBS', 'TOT_VIBSMUN', 'TOT_VIBSUF');
var
  Q: TZQuery;
  I: integer;
begin
  // valores inteiros no primeiro dia: o SQLite os grava como INTEGER e não podem truncar os dias seguintes
  InserirNFeTotais('A', EncodeDateTime(2026, 11, 4, 10, 0, 0, 0), 100, [2, 3]);
  InserirNFeTotais('B', EncodeDateTime(2026, 11, 5, 8, 0, 0, 0), 1.25, [1.5]);
  InserirNFeTotais('C', EncodeDateTime(2026, 11, 5, 23, 59, 59, 0), 10, []);
  InserirNFeTotais('D', EncodeDateTime(2026, 11, 6, 10, 0, 0, 0), 7, [1]);

  dmdNFe.FiltrarNFeCab(EncodeDate(2026, 11, 4), EncodeDate(2026, 11, 5));
  dmdNFe.AbrirTotaisSintetico;
  Q := dmdNFe.qryTotaisSintetico;
  AssertEquals('dias', 2, Q.RecordCount);

  AssertEquals('dia 04', '04/11/2026', Q.FieldByName('DIA').AsString);
  AssertEquals('vendas dia 04', 1, Q.FieldByName('QTD_VENDAS').AsInteger);
  AssertEquals('produtos dia 04', 5, Q.FieldByName('QTD_PRODUTOS').AsFloat, 0.00001);
  for I := 0 to High(CAMPOS) do
    AssertEquals(CAMPOS[I] + ' dia 04', 100 + I, Q.FieldByName(CAMPOS[I]).AsFloat, 0.001);

  Q.Next;
  AssertEquals('dia 05', '05/11/2026', Q.FieldByName('DIA').AsString);
  AssertEquals('vendas dia 05', 2, Q.FieldByName('QTD_VENDAS').AsInteger);
  // nota sem itens não altera a quantidade de produtos
  AssertEquals('produtos dia 05', 1.5, Q.FieldByName('QTD_PRODUTOS').AsFloat, 0.00001);
  for I := 0 to High(CAMPOS) do
    AssertEquals(CAMPOS[I] + ' dia 05', 11.25 + 2 * I, Q.FieldByName(CAMPOS[I]).AsFloat, 0.001);
end;

procedure TTesteDmdNFe.TestTotaisSinteticoSemFiltro;
begin
  InserirNotasNovembro;
  // sem FiltrarNFeCab os parâmetros ficam nulos e nenhuma nota é considerada
  dmdNFe.AbrirTotaisSintetico;
  AssertTrue('vazio', dmdNFe.qryTotaisSintetico.IsEmpty);
end;

initialization
  RegisterTest(TTesteDmdNFe);

end.
