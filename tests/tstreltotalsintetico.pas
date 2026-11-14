unit tstreltotalsintetico;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, ZConnection, ZDataset;

type

  { TTesteRelTotaisSintetico }

  TTesteRelTotaisSintetico = class(TTestCase)
  private
    FPasta: string;
    FConexao: TZConnection;
    procedure InserirNFeTotais(const Chave: string; DataEmissao: TDateTime; Valor: double;
      Quantidade: double);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSomaDeTodosOsDias;
  end;

implementation

uses
  Forms, FileUtil, DateUtils, udmdnfe, ureltotalsintetico;

{ TTesteRelTotaisSintetico }

procedure TTesteRelTotaisSintetico.SetUp;
var
  I: integer;
begin
  // o executor de testes não inicializa o widgetset, necessário para criar forms
  if not (AppInitialized in Application.Flags) then
    Application.Initialize;

  FPasta := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'nfestudio-teste-reltotais-' +
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

procedure TTesteRelTotaisSintetico.TearDown;
begin
  FreeAndNil(relTotaisSintetico);
  FreeAndNil(dmdNFe);
  FConexao.Free;
  DeleteDirectory(FPasta, False);
end;

procedure TTesteRelTotaisSintetico.InserirNFeTotais(const Chave: string; DataEmissao: TDateTime;
  Valor: double; Quantidade: double);
var
  Q: TZQuery;
begin
  Q := TZQuery.Create(nil);
  try
    Q.Connection := FConexao;
    Q.SQL.Text := 'INSERT INTO NFE_CAB (CHNFE, IDE_DHEMI, TOT_VNF, TOT_VICMS, IBSUFTOT_VIBSUF) ' +
      'VALUES (:CHNFE, :IDE_DHEMI, :VNF, :VICMS, :VIBSUF)';
    Q.ParamByName('CHNFE').AsString := Chave;
    Q.ParamByName('IDE_DHEMI').AsDateTime := DataEmissao;
    Q.ParamByName('VNF').AsFloat := Valor;
    Q.ParamByName('VICMS').AsFloat := Valor / 10;
    Q.ParamByName('VIBSUF').AsFloat := Valor / 100;
    Q.ExecSQL;
    Q.SQL.Text := 'INSERT INTO NFE_DET (CHNFE, NITEM, QCOM) VALUES (:CHNFE, 1, :QCOM)';
    Q.ParamByName('CHNFE').AsString := Chave;
    Q.ParamByName('QCOM').AsFloat := Quantidade;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TTesteRelTotaisSintetico.TestSomaDeTodosOsDias;
begin
  InserirNFeTotais('A', EncodeDateTime(2026, 11, 4, 10, 0, 0, 0), 100, 2);
  InserirNFeTotais('B', EncodeDateTime(2026, 11, 5, 8, 0, 0, 0), 1.25, 1.5);
  InserirNFeTotais('C', EncodeDateTime(2026, 11, 5, 9, 0, 0, 0), 10, 3);
  InserirNFeTotais('D', EncodeDateTime(2026, 11, 6, 9, 0, 0, 0), 50, 1);

  dmdNFe.FiltrarNFeCab(EncodeDate(2026, 11, 4), EncodeDate(2026, 11, 5));
  dmdNFe.AbrirTotaisSintetico;
  relTotaisSintetico := TrelTotaisSintetico.Create(nil);
  AssertEquals('período', 'Período: ' + DateToStr(EncodeDate(2026, 11, 4)) + ' a ' +
    DateToStr(EncodeDate(2026, 11, 5)), relTotaisSintetico.rllPeriodo.Caption);

  AssertTrue('preparado', relTotaisSintetico.rlrTotaisSintetico.Prepare);
  // o rodapé soma os dias do filtro; a nota do dia 06 fica de fora
  AssertEquals('vendas', 3, Integer(relTotaisSintetico.rdrQtdVendas.Value));
  AssertEquals('total vendas', 111.25, Double(relTotaisSintetico.rdrTotVendas.Value), 0.001);
  AssertEquals('produtos', 6.5, Double(relTotaisSintetico.rdrQtdProdutos.Value), 0.00001);
  AssertEquals('ICMS', 11.125, Double(relTotaisSintetico.rdrICMS.Value), 0.001);
  AssertEquals('IBS estadual', 1.1125, Double(relTotaisSintetico.rdrIBSUF.Value), 0.0001);
  AssertEquals('PIS sem valor', 0, Double(relTotaisSintetico.rdrPIS.Value), 0.001);
end;

initialization
  RegisterTest(TTesteRelTotaisSintetico);

end.
