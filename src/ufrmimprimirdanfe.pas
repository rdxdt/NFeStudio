unit ufrmimprimirdanfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, StdCtrls, ExtCtrls;

type

  TTipoDANFE = (tdPOS, tdBobina, tdA4);

  { TfrmImprimirDANFE }

  TfrmImprimirDANFE = class(TForm)
    lblModelo: TLabel;
    grpDANFE: TGroupBox;
    rbtPOS: TRadioButton;
    rbtBobina: TRadioButton;
    rbtA4: TRadioButton;
    pnlBotoes: TPanel;
    btnImprimir: TButton;
    btnCancelar: TButton;
  public
    procedure Configurar(Modelo: integer; Padrao: TTipoDANFE);
    function TipoSelecionado: TTipoDANFE;
    class function Selecionar(Modelo: integer; Padrao: TTipoDANFE; out Tipo: TTipoDANFE): Boolean;
  end;

const
  MODELO_NFCE = 65;

var
  frmImprimirDANFE: TfrmImprimirDANFE;

implementation

{$R *.lfm}

const
  MSG_MODELO_NFE = 'NF-e (modelo 55)';
  MSG_MODELO_NFCE = 'NFC-e (modelo 65)';

{ TfrmImprimirDANFE }

class function TfrmImprimirDANFE.Selecionar(Modelo: integer; Padrao: TTipoDANFE;
  out Tipo: TTipoDANFE): Boolean;
begin
  frmImprimirDANFE := TfrmImprimirDANFE.Create(Application);
  try
    frmImprimirDANFE.Configurar(Modelo, Padrao);
    Result := frmImprimirDANFE.ShowModal = mrOK;
    Tipo := frmImprimirDANFE.TipoSelecionado;
  finally
    FreeAndNil(frmImprimirDANFE);
  end;
end;

procedure TfrmImprimirDANFE.Configurar(Modelo: integer; Padrao: TTipoDANFE);
begin
  // as opções em bobina são exclusivas da NFC-e; a NF-e só tem DANFE em A4
  rbtPOS.Visible := Modelo = MODELO_NFCE;
  rbtBobina.Visible := Modelo = MODELO_NFCE;
  if Modelo = MODELO_NFCE then
    lblModelo.Caption := MSG_MODELO_NFCE
  else
  begin
    lblModelo.Caption := MSG_MODELO_NFE;
    Padrao := tdA4;
  end;
  case Padrao of
    tdPOS: rbtPOS.Checked := True;
    tdBobina: rbtBobina.Checked := True;
  else
    rbtA4.Checked := True;
  end;
end;

function TfrmImprimirDANFE.TipoSelecionado: TTipoDANFE;
begin
  if rbtPOS.Checked then
    Result := tdPOS
  else if rbtBobina.Checked then
    Result := tdBobina
  else
    Result := tdA4;
end;

end.
