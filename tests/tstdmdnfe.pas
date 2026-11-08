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
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestFiltroIgnoraHoraDosParametros;
    procedure TestFiltroPeriodo;
    procedure TestPeriodoTabelaVazia;
    procedure TestPeriodoMenorEMaiorData;
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

initialization
  RegisterTest(TTesteDmdNFe);

end.
