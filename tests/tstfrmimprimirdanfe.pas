unit tstfrmimprimirdanfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, ufrmimprimirdanfe;

type

  { TTesteFrmImprimirDANFE }

  TTesteFrmImprimirDANFE = class(TTestCase)
  private
    FForm: TfrmImprimirDANFE;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestNFeSomenteA4;
    procedure TestNFCeTodasAsOpcoes;
    procedure TestNFCePadraoPOS;
    procedure TestNFCePadraoA4;
  end;

implementation

uses
  Forms;

const
  MODELO_NFE = 55;

{ TTesteFrmImprimirDANFE }

procedure TTesteFrmImprimirDANFE.SetUp;
begin
  // o executor de testes não inicializa o widgetset, necessário para criar forms
  if not (AppInitialized in Application.Flags) then
    Application.Initialize;
  FForm := TfrmImprimirDANFE.Create(nil);
end;

procedure TTesteFrmImprimirDANFE.TearDown;
begin
  FForm.Free;
end;

procedure TTesteFrmImprimirDANFE.TestNFeSomenteA4;
begin
  // mesmo com POS configurada como padrão, a NF-e só oferece A4
  FForm.Configurar(MODELO_NFE, tdPOS);
  AssertFalse('POS oculta', FForm.rbtPOS.Visible);
  AssertFalse('bobina oculta', FForm.rbtBobina.Visible);
  AssertTrue('A4 visível', FForm.rbtA4.Visible);
  AssertTrue('A4 selecionada', FForm.TipoSelecionado = tdA4);
end;

procedure TTesteFrmImprimirDANFE.TestNFCeTodasAsOpcoes;
begin
  FForm.Configurar(MODELO_NFCE, tdBobina);
  AssertTrue('POS visível', FForm.rbtPOS.Visible);
  AssertTrue('bobina visível', FForm.rbtBobina.Visible);
  AssertTrue('A4 visível', FForm.rbtA4.Visible);
  AssertTrue('bobina selecionada', FForm.TipoSelecionado = tdBobina);
end;

procedure TTesteFrmImprimirDANFE.TestNFCePadraoPOS;
begin
  FForm.Configurar(MODELO_NFCE, tdPOS);
  AssertTrue('POS selecionada', FForm.TipoSelecionado = tdPOS);
end;

procedure TTesteFrmImprimirDANFE.TestNFCePadraoA4;
begin
  FForm.Configurar(MODELO_NFCE, tdA4);
  AssertTrue('A4 selecionada', FForm.TipoSelecionado = tdA4);
end;

initialization
  RegisterTest(TTesteFrmImprimirDANFE);

end.
