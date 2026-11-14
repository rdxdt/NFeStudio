unit tstfrmrelatorios;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, ufrmrelatorios;

type

  { TTesteFrmRelatorios }

  TTesteFrmRelatorios = class(TTestCase)
  private
    FForm: TfrmRelatorios;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestOpcaoTotaisSintetico;
    procedure TestFecharCancelaForm;
  end;

implementation

uses
  Forms, Controls;

{ TTesteFrmRelatorios }

procedure TTesteFrmRelatorios.SetUp;
begin
  // o executor de testes não inicializa o widgetset, necessário para criar forms
  if not (AppInitialized in Application.Flags) then
    Application.Initialize;
  FForm := TfrmRelatorios.Create(nil);
end;

procedure TTesteFrmRelatorios.TearDown;
begin
  FForm.Free;
end;

procedure TTesteFrmRelatorios.TestOpcaoTotaisSintetico;
begin
  AssertTrue('visível', FForm.btnTotaisSintetico.Visible);
  AssertTrue('habilitado', FForm.btnTotaisSintetico.Enabled);
  AssertTrue('na lista de relatórios', FForm.btnTotaisSintetico.Parent = FForm.grpRelatorios);
  AssertTrue('OnClick ligado', Assigned(FForm.btnTotaisSintetico.OnClick));
  // o botão só gera o relatório; não fecha o form de opções
  AssertEquals('não fecha o form', Ord(mrNone), Ord(FForm.btnTotaisSintetico.ModalResult));
end;

procedure TTesteFrmRelatorios.TestFecharCancelaForm;
begin
  AssertTrue('Esc fecha', FForm.btnFechar.Cancel);
  AssertEquals('ModalResult', Ord(mrCancel), Ord(FForm.btnFechar.ModalResult));
end;

initialization
  RegisterTest(TTesteFrmRelatorios);

end.
