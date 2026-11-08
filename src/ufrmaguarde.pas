unit ufrmaguarde;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls, ComCtrls;

type

  { TfrmAguarde }

  TfrmAguarde = class(TForm)
    pnlFundo: TPanel;
    lblTitulo: TLabel;
    lblMensagem: TLabel;
    pgbProgresso: TProgressBar;
    lblProgresso: TLabel;
    procedure FormDestroy(Sender: TObject);
  public
    procedure Exibir(const Mensagem: string = '');
    procedure AtualizarProgresso(Atual, Total: integer);
  end;

var
  frmAguarde: TfrmAguarde;

implementation

{$R *.lfm}

const
  MSG_PROGRESSO = '%d de %d arquivos';

{ TfrmAguarde }

procedure TfrmAguarde.Exibir(const Mensagem: string);
begin
  if Mensagem <> '' then
    lblMensagem.Caption := Mensagem;
  Screen.Cursor := crHourGlass;
  // o processamento chama Application.ProcessMessages; o form principal é desabilitado
  // para que cliques nele (ex.: importar novamente) não sejam executados durante o processamento
  if Assigned(Application.MainForm) then
    Application.MainForm.Enabled := False;
  Show;
  // força a pintura do diálogo antes do processamento síncrono que vem em seguida
  Update;
  Application.ProcessMessages;
end;

procedure TfrmAguarde.AtualizarProgresso(Atual, Total: integer);
begin
  pgbProgresso.Max := Total;
  pgbProgresso.Position := Atual;
  lblProgresso.Caption := Format(MSG_PROGRESSO, [Atual, Total]);
end;

procedure TfrmAguarde.FormDestroy(Sender: TObject);
begin
  if Assigned(Application.MainForm) then
    Application.MainForm.Enabled := True;
  Screen.Cursor := crDefault;
end;

end.
