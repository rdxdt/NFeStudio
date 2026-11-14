unit ufrmrelatorios;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls;

type

  { TfrmRelatorios }

  TfrmRelatorios = class(TForm)
    grpRelatorios: TGroupBox;
    btnTotaisSintetico: TButton;
    pnlBotoes: TPanel;
    btnFechar: TButton;
    procedure btnTotaisSinteticoClick(Sender: TObject);
  public
    class procedure Exibir;
  end;

var
  frmRelatorios: TfrmRelatorios;

implementation

uses
  ureltotalsintetico;

{$R *.lfm}

{ TfrmRelatorios }

class procedure TfrmRelatorios.Exibir;
begin
  frmRelatorios := TfrmRelatorios.Create(Application);
  try
    frmRelatorios.ShowModal;
  finally
    FreeAndNil(frmRelatorios);
  end;
end;

procedure TfrmRelatorios.btnTotaisSinteticoClick(Sender: TObject);
begin
  TrelTotaisSintetico.Exibir;
end;

end.
