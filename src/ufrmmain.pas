unit ufrmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, DBGrids, ComCtrls, ACBrNFe, ACBrNFeDANFeRLClass, ACBrPosPrinter,
  ACBrNFeDANFeESCPOS, ACBrDANFCeFortesFrA4, ACBrDANFCeFortesFr, ZConnection,
  DateTimePicker;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    ACBrNFe1: TACBrNFe;
    ACBrNFeDANFCeFortes1: TACBrNFeDANFCeFortes;
    ACBrNFeDANFCeFortesA4_1: TACBrNFeDANFCeFortesA4;
    ACBrNFeDANFeESCPOS1: TACBrNFeDANFeESCPOS;
    ACBrNFeDANFeRL1: TACBrNFeDANFeRL;
    ACBrPosPrinter1: TACBrPosPrinter;
    btnAbrir: TButton;
    DataSource1: TDataSource;
    dtpInicial: TDateTimePicker;
    dtpFinal: TDateTimePicker;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    pnlTopBar: TPanel;
    pnlMenu: TPanel;
    btnMenu: TSpeedButton;
    StatusBar1: TStatusBar;
    ZConnection1: TZConnection;
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

end.

