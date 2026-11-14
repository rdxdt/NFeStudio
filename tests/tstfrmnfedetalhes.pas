unit tstfrmnfedetalhes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, ZConnection, ZDataset, ACBrNFe,
  uprocessadornfe;

type

  { TTesteFrmNFeDetalhes }

  TTesteFrmNFeDetalhes = class(TTestCase)
  private
    FPasta: string;
    FConexao: TZConnection;
    FACBrNFe: TACBrNFe;
    FProcessador: TProcessadorNFe;
    FChaveImpressa: string;
    procedure RegistrarImpressao(const Chave: string);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestExibeNotaSelecionada;
    procedure TestFechaSomenteDetalhesQueAbriu;
    procedure TestImprimirSemHandlerDesabilitado;
    procedure TestImprimirEnviaChaveDaNota;
  end;

implementation

uses
  Forms, FileUtil, udmdnfe, ufrmnfedetalhes;

const
  CHAVE_PROCNFE = '35150905481336000137550010000111291000111298';
  ARQUIVO_PROCNFE = CHAVE_PROCNFE + '-nfe.xml';

function PastaFixtures: string;
begin
  // o executável é gerado em bin/linux64/tests e as fixtures ficam em tests/fixtures
  Result := ExpandFileName(ExtractFilePath(ParamStr(0)) + '../../../tests/fixtures') + PathDelim;
end;

{ TTesteFrmNFeDetalhes }

procedure TTesteFrmNFeDetalhes.SetUp;
var
  I: integer;
begin
  // o executor de testes não inicializa o widgetset, necessário para criar forms
  if not (AppInitialized in Application.Flags) then
    Application.Initialize;

  FPasta := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'nfestudio-teste-detalhes-' +
    IntToStr(GetProcessID) + PathDelim;
  DeleteDirectory(FPasta, False);
  ForceDirectories(FPasta + 'notas');
  CopyFile(PastaFixtures + ARQUIVO_PROCNFE, FPasta + 'notas' + PathDelim + ARQUIVO_PROCNFE);

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
  FProcessador.Importar(FPasta + 'notas');
  dmdNFe.FiltrarNFeCab(EncodeDate(2015, 9, 23), EncodeDate(2015, 9, 23));
end;

procedure TTesteFrmNFeDetalhes.TearDown;
begin
  FreeAndNil(frmNFeDetalhes);
  FProcessador.Free;
  FACBrNFe.Free;
  FreeAndNil(dmdNFe);
  FConexao.Free;
  DeleteDirectory(FPasta, False);
end;

procedure TTesteFrmNFeDetalhes.TestExibeNotaSelecionada;
begin
  // o form não é exibido; criá-lo carrega o lfm e abre os detalhes
  frmNFeDetalhes := TfrmNFeDetalhes.Create(nil);
  AssertEquals('chave', CHAVE_PROCNFE, frmNFeDetalhes.edtResumoChnfe.Text);
  AssertEquals('emitente', dmdNFe.qryNFeCab.FieldByName('EMIT_XNOME').AsString,
    frmNFeDetalhes.edtEmitXnome.Text);
  AssertEquals('item', 'TESTE DE PRODUTO', frmNFeDetalhes.edtItemXprod.Text);
  AssertEquals('fatura', dmdNFe.qryNFeFat.FieldByName('NFAT').AsString, frmNFeDetalhes.edtFatNfat.Text);
  AssertEquals('duplicatas', 2, dmdNFe.qryNFeDup.RecordCount);
  AssertEquals('volumes', 1, dmdNFe.qryNFeVol.RecordCount);
  AssertTrue('pagamentos abertos', dmdNFe.qryNFePgt.Active);
  AssertEquals('informações complementares no memo',
    Trim(dmdNFe.qryNFeCab.FieldByName('INFADIC_INFCPL').AsString), Trim(frmNFeDetalhes.mmoInfadicInfcpl.Text));
end;

procedure TTesteFrmNFeDetalhes.TestFechaSomenteDetalhesQueAbriu;
begin
  // qryNFeDup já estava aberta antes do form e deve continuar aberta
  dmdNFe.qryNFeDup.Open;
  frmNFeDetalhes := TfrmNFeDetalhes.Create(nil);
  AssertTrue('itens abertos', dmdNFe.qryNFeDet.Active);
  FreeAndNil(frmNFeDetalhes);
  AssertFalse('itens fechados', dmdNFe.qryNFeDet.Active);
  AssertFalse('fatura fechada', dmdNFe.qryNFeFat.Active);
  AssertFalse('volumes fechados', dmdNFe.qryNFeVol.Active);
  AssertFalse('pagamentos fechados', dmdNFe.qryNFePgt.Active);
  AssertTrue('duplicatas continuam abertas', dmdNFe.qryNFeDup.Active);
end;

procedure TTesteFrmNFeDetalhes.RegistrarImpressao(const Chave: string);
begin
  FChaveImpressa := Chave;
end;

procedure TTesteFrmNFeDetalhes.TestImprimirSemHandlerDesabilitado;
begin
  frmNFeDetalhes := TfrmNFeDetalhes.Create(nil);
  AssertFalse('imprimir desabilitado', frmNFeDetalhes.tbtImprimir.Enabled);
end;

procedure TTesteFrmNFeDetalhes.TestImprimirEnviaChaveDaNota;
begin
  FChaveImpressa := '';
  frmNFeDetalhes := TfrmNFeDetalhes.Create(nil);
  frmNFeDetalhes.OnImprimirDANFE := @RegistrarImpressao;
  AssertTrue('imprimir habilitado', frmNFeDetalhes.tbtImprimir.Enabled);
  frmNFeDetalhes.tbtImprimir.Click;
  AssertEquals('chave enviada', CHAVE_PROCNFE, FChaveImpressa);
end;

initialization
  RegisterTest(TTesteFrmNFeDetalhes);

end.
