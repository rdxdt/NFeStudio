unit ufrmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, DBGrids, DBCtrls, ComCtrls, Menus, ACBrNFe, ACBrNFeDANFeRLClass,
  ACBrPosPrinter, ACBrNFeDANFeESCPOS, ACBrDANFCeFortesFrA4, ACBrDANFCeFortesFr,
  ZConnection, DateTimePicker, IniFiles,uprocessadornfe, ACBrDFeDANFeReport,
  ufrmimprimirdanfe;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    ACBrNFe1: TACBrNFe;
    ACBrNFeDANFCeFortes1: TACBrNFeDANFCeFortes;
    ACBrNFeDANFCeFortesA4_1: TACBrNFeDANFCeFortesA4;
    ACBrNFeDANFeESCPOS1: TACBrNFeDANFeESCPOS;
    ACBrNFeDANFeRL1: TACBrNFeDANFeRL;
    ACBrPosPrinter1: TACBrPosPrinter;
    btnFiltrar: TButton;
    dtpInicial: TDateTimePicker;
    dtpFinal: TDateTimePicker;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    pnlTopBar: TPanel;
    pnlMenu: TPanel;
    btnMenu: TSpeedButton;
    dlgSelDir: TSelectDirectoryDialog;
    btnImportarXML: TSpeedButton;
    btnRelatorios: TSpeedButton;
    btnConfig: TSpeedButton;
    StatusBar1: TStatusBar;
    ZConnection1: TZConnection;
    pnlDetalhes: TPanel;
    pgcDetalhes: TPageControl;
    tabDestinatario: TTabSheet;
    sbxDestinatario: TScrollBox;
    lblDestCNPJCPF: TLabel;
    edtDestCNPJCPF: TDBEdit;
    lblDestIdEstrangeiro: TLabel;
    edtDestIdEstrangeiro: TDBEdit;
    lblDestXNome: TLabel;
    edtDestXNome: TDBEdit;
    lblDestIE: TLabel;
    edtDestIE: TDBEdit;
    lblDestIndIEDest: TLabel;
    edtDestIndIEDest: TDBEdit;
    lblDestIM: TLabel;
    edtDestIM: TDBEdit;
    lblDestISUF: TLabel;
    edtDestISUF: TDBEdit;
    lblDestFone: TLabel;
    edtDestFone: TDBEdit;
    lblDestEmail: TLabel;
    edtDestEmail: TDBEdit;
    lblDestXLgr: TLabel;
    edtDestXLgr: TDBEdit;
    lblDestNro: TLabel;
    edtDestNro: TDBEdit;
    lblDestXCpl: TLabel;
    edtDestXCpl: TDBEdit;
    lblDestXBairro: TLabel;
    edtDestXBairro: TDBEdit;
    lblDestCMun: TLabel;
    edtDestCMun: TDBEdit;
    lblDestXMun: TLabel;
    edtDestXMun: TDBEdit;
    lblDestUF: TLabel;
    edtDestUF: TDBEdit;
    lblDestCEP: TLabel;
    edtDestCEP: TDBEdit;
    lblDestCPais: TLabel;
    edtDestCPais: TDBEdit;
    lblDestXPais: TLabel;
    edtDestXPais: TDBEdit;
    tabTotaisICMS: TTabSheet;
    sbxTotaisICMS: TScrollBox;
    lblTotVBC: TLabel;
    edtTotVBC: TDBEdit;
    lblTotVICMS: TLabel;
    edtTotVICMS: TDBEdit;
    lblTotVICMSDeson: TLabel;
    edtTotVICMSDeson: TDBEdit;
    lblTotVFCP: TLabel;
    edtTotVFCP: TDBEdit;
    lblTotVBCST: TLabel;
    edtTotVBCST: TDBEdit;
    lblTotVST: TLabel;
    edtTotVST: TDBEdit;
    lblTotVFCPST: TLabel;
    edtTotVFCPST: TDBEdit;
    lblTotVFCPSTRet: TLabel;
    edtTotVFCPSTRet: TDBEdit;
    lblTotVFCPUFDest: TLabel;
    edtTotVFCPUFDest: TDBEdit;
    lblTotVICMSUFDest: TLabel;
    edtTotVICMSUFDest: TDBEdit;
    lblTotVICMSUFRemet: TLabel;
    edtTotVICMSUFRemet: TDBEdit;
    lblTotVProd: TLabel;
    edtTotVProd: TDBEdit;
    lblTotVFrete: TLabel;
    edtTotVFrete: TDBEdit;
    lblTotVSeg: TLabel;
    edtTotVSeg: TDBEdit;
    lblTotVDesc: TLabel;
    edtTotVDesc: TDBEdit;
    lblTotVOutro: TLabel;
    edtTotVOutro: TDBEdit;
    lblTotVII: TLabel;
    edtTotVII: TDBEdit;
    lblTotVIPI: TLabel;
    edtTotVIPI: TDBEdit;
    lblTotVIPIDevol: TLabel;
    edtTotVIPIDevol: TDBEdit;
    lblTotVPIS: TLabel;
    edtTotVPIS: TDBEdit;
    lblTotVCOFINS: TLabel;
    edtTotVCOFINS: TDBEdit;
    lblTotVTotTrib: TLabel;
    edtTotVTotTrib: TDBEdit;
    lblTotQBCMono: TLabel;
    edtTotQBCMono: TDBEdit;
    lblTotVICMSMono: TLabel;
    edtTotVICMSMono: TDBEdit;
    lblTotQBCMonoReten: TLabel;
    edtTotQBCMonoReten: TDBEdit;
    lblTotVICMSMonoReten: TLabel;
    edtTotVICMSMonoReten: TDBEdit;
    lblTotQBCMonoRet: TLabel;
    edtTotQBCMonoRet: TDBEdit;
    lblTotVICMSMonoRet: TLabel;
    edtTotVICMSMonoRet: TDBEdit;
    lblTotVNF: TLabel;
    edtTotVNF: TDBEdit;
    tabTotaisISSQN: TTabSheet;
    sbxTotaisISSQN: TScrollBox;
    lblISSQNTotVServ: TLabel;
    edtISSQNTotVServ: TDBEdit;
    lblISSQNTotVBC: TLabel;
    edtISSQNTotVBC: TDBEdit;
    lblISSQNTotVISS: TLabel;
    edtISSQNTotVISS: TDBEdit;
    lblISSQNTotVISSRet: TLabel;
    edtISSQNTotVISSRet: TDBEdit;
    lblISSQNTotVPIS: TLabel;
    edtISSQNTotVPIS: TDBEdit;
    lblISSQNTotVCOFINS: TLabel;
    edtISSQNTotVCOFINS: TDBEdit;
    lblISSQNTotVDeducao: TLabel;
    edtISSQNTotVDeducao: TDBEdit;
    lblISSQNTotVOutro: TLabel;
    edtISSQNTotVOutro: TDBEdit;
    lblISSQNTotVDescIncond: TLabel;
    edtISSQNTotVDescIncond: TDBEdit;
    lblISSQNTotVDescCond: TLabel;
    edtISSQNTotVDescCond: TDBEdit;
    lblISSQNTotDCompet: TLabel;
    edtISSQNTotDCompet: TDBEdit;
    lblISSQNTotCRegTrib: TLabel;
    edtISSQNTotCRegTrib: TDBEdit;
    tabRetencoes: TTabSheet;
    sbxRetencoes: TScrollBox;
    lblRetTribVRetPIS: TLabel;
    edtRetTribVRetPIS: TDBEdit;
    lblRetTribVRetCOFINS: TLabel;
    edtRetTribVRetCOFINS: TDBEdit;
    lblRetTribVRetCSLL: TLabel;
    edtRetTribVRetCSLL: TDBEdit;
    lblRetTribVBCIRRF: TLabel;
    edtRetTribVBCIRRF: TDBEdit;
    lblRetTribVIRRF: TLabel;
    edtRetTribVIRRF: TDBEdit;
    lblRetTribVBCRetPrev: TLabel;
    edtRetTribVBCRetPrev: TDBEdit;
    lblRetTribVRetPrev: TLabel;
    edtRetTribVRetPrev: TDBEdit;
    tabTotaisIBSCBS: TTabSheet;
    sbxTotaisIBSCBS: TScrollBox;
    lblISTotVIS: TLabel;
    edtISTotVIS: TDBEdit;
    lblIBSCBSTotVBCIBSCBS: TLabel;
    edtIBSCBSTotVBCIBSCBS: TDBEdit;
    lblIBSTotVIBS: TLabel;
    edtIBSTotVIBS: TDBEdit;
    lblCBSTotVCBS: TLabel;
    edtCBSTotVCBS: TDBEdit;
    lblIBSUFTotVIBSUF: TLabel;
    edtIBSUFTotVIBSUF: TDBEdit;
    lblIBSUFTotVDif: TLabel;
    edtIBSUFTotVDif: TDBEdit;
    lblIBSUFTotVDevTrib: TLabel;
    edtIBSUFTotVDevTrib: TDBEdit;
    lblIBSTotVCredPres: TLabel;
    edtIBSTotVCredPres: TDBEdit;
    lblIBSMunTotVIBSMun: TLabel;
    edtIBSMunTotVIBSMun: TDBEdit;
    lblIBSMunTotVDif: TLabel;
    edtIBSMunTotVDif: TDBEdit;
    lblIBSMunTotVDevTrib: TLabel;
    edtIBSMunTotVDevTrib: TDBEdit;
    lblIBSTotVCredPresCondSus: TLabel;
    edtIBSTotVCredPresCondSus: TDBEdit;
    lblCBSTotVDif: TLabel;
    edtCBSTotVDif: TDBEdit;
    lblCBSTotVDevTrib: TLabel;
    edtCBSTotVDevTrib: TDBEdit;
    lblCBSTotVCredPres: TLabel;
    edtCBSTotVCredPres: TDBEdit;
    lblCBSTotVCredPresCondSus: TLabel;
    edtCBSTotVCredPresCondSus: TDBEdit;
    lblMonoTotVIBSMono: TLabel;
    edtMonoTotVIBSMono: TDBEdit;
    lblMonoTotVCBSMono: TLabel;
    edtMonoTotVCBSMono: TDBEdit;
    lblMonoTotVIBSMonoReten: TLabel;
    edtMonoTotVIBSMonoReten: TDBEdit;
    lblMonoTotVCBSMonoReten: TLabel;
    edtMonoTotVCBSMonoReten: TDBEdit;
    lblMonoTotVIBSMonoRet: TLabel;
    edtMonoTotVIBSMonoRet: TDBEdit;
    lblMonoTotVCBSMonoRet: TLabel;
    edtMonoTotVCBSMonoRet: TDBEdit;
    lblTotVNFTot: TLabel;
    edtTotVNFTot: TDBEdit;
    ProcessadorNFe : TProcessadorNFe;
    procedure btnFiltrarClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure btnImportarXMLClick(Sender: TObject);
    procedure btnMenuClick(Sender: TObject);
    procedure btnRelatoriosClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
  private
    function ArquivoIni: string;
    function PastaDocumentos: string;
    function PastaSchemas: string;
    procedure DefinirPathsPadraoNFe;
    procedure CriarPastasNFe;
    procedure GravarConfigPosPrinter(Ini: TCustomIniFile);
    procedure LerConfigPosPrinter(Ini: TCustomIniFile);
    procedure SelecionarDANFE(const Componente: string);
    procedure CriarArquivoIni(Ini: TCustomIniFile);
    procedure CarregarConfiguracoes;
    procedure InicializarBanco;
    procedure AjustarPeriodoFiltro;
    function TipoDANFEPadrao: TTipoDANFE;
    function ComponenteDANFE(Tipo: TTipoDANFE; Modelo: integer): TACBrDFeDANFeReport;
  public
    procedure ImprimirDANFE(const Chave: string);

  end;

var
  frmMain: TfrmMain;

implementation

uses
  {$IFDEF MSWINDOWS}
  WinDirs,
  {$ENDIF}
  udmdnfe, ufrmconfig, ufrmnfedetalhes, ufrmrelatorios;

{$R *.lfm}

const
  SECAO_DANFE = 'DANFE';
  SECAO_POSPRINTER = 'PosPrinter';
  DANFE_RL = 'RL';
  DANFE_ESCPOS = 'ESCPOS';
  DANFE_FORTES = 'FORTES';
  DANFE_FORTESA4 = 'FORTESA4';
  MSG_SEM_XML = 'XML da NFe %s n'#227'o encontrado no banco. Reimporte a nota para imprimir a DANFE.';
  MSG_ERRO_CONSULTA = 'Não foi possível consultar o protocolo da NFe %s na SEFAZ:'#10'%s'#10#10 +
    'A DANFE será impressa sem protocolo.';

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  CarregarConfiguracoes;
  InicializarBanco;
  dlgSelDir.InitialDir:= ACBrNFe1.Configuracoes.Arquivos.GetPathNFe(Now);
  ProcessadorNFe := TProcessadorNFe.Create(frmMain);
  ProcessadorNFe.ACBrNFe:= ACBrNFe1;
  ProcessadorNFe.ExibirProgresso := True;
end;

procedure TfrmMain.btnConfigClick(Sender: TObject);
begin
  if TfrmConfig.Executar(ArquivoIni) then
    CarregarConfiguracoes;
  pnlMenu.Visible := False;
end;

procedure TfrmMain.btnMenuClick(Sender: TObject);
begin
  pnlMenu.Visible := not pnlMenu.Visible;
end;

procedure TfrmMain.btnImportarXMLClick(Sender: TObject);
begin
  if not dlgSelDir.Execute then
    Exit;
  try
    ProcessadorNFe.Importar(dlgSelDir.FileName);
  except on E:Exception do
    MessageDlg(E.Message,mtError,[mbOK],0);
  end;
  // mesmo com erro, parte das notas pode ter sido gravada
  AjustarPeriodoFiltro;
  pnlMenu.Visible := False;
end;

procedure TfrmMain.btnFiltrarClick(Sender: TObject);
begin
  dmdNFe.FiltrarNFeCab(dtpInicial.Date, dtpFinal.Date);
end;

procedure TfrmMain.DBGrid1DblClick(Sender: TObject);
begin
  TfrmNFeDetalhes.Exibir(@ImprimirDANFE);
end;

procedure TfrmMain.btnRelatoriosClick(Sender: TObject);
begin
  pnlMenu.Visible := False;
  TfrmRelatorios.Exibir;
end;

function TfrmMain.ArquivoIni: string;
begin
  Result := IncludeTrailingPathDelimiter(GetAppConfigDir(False)) +
    ChangeFileExt(ExtractFileName(Application.ExeName), '.ini');
end;

function TfrmMain.PastaDocumentos: string;
{$IFNDEF MSWINDOWS}
var
  ArqUserDirs: string;
  UserDirs: TStringList;
{$ENDIF}
begin
  {$IFDEF MSWINDOWS}
  Result := GetWindowsSpecialDir(CSIDL_PERSONAL);
  {$ELSE}
  // No Linux o nome da pasta de documentos é localizado (ex.: ~/Documentos) e
  // definido pelo xdg-user-dirs em ~/.config/user-dirs.dirs
  Result := '';
  ArqUserDirs := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if ArqUserDirs = '' then
    ArqUserDirs := GetUserDir + '.config';
  ArqUserDirs := IncludeTrailingPathDelimiter(ArqUserDirs) + 'user-dirs.dirs';
  if FileExists(ArqUserDirs) then
  begin
    UserDirs := TStringList.Create;
    try
      UserDirs.LoadFromFile(ArqUserDirs);
      Result := AnsiDequotedStr(UserDirs.Values['XDG_DOCUMENTS_DIR'], '"');
      Result := StringReplace(Result, '$HOME', ExcludeTrailingPathDelimiter(GetUserDir), []);
    finally
      UserDirs.Free;
    end;
  end;
  if Result = '' then
    Result := GetUserDir + 'Documents';
  {$ENDIF}
  Result := IncludeTrailingPathDelimiter(Result);
end;

function TfrmMain.PastaSchemas: string;
begin
  Result := ExtractFilePath(Application.ExeName);
  {$IFDEF UNIX}
  // Instalado por pacote, o executável fica em /usr/bin e os schemas em /usr/share/<app>
  if DirectoryExists(Result + '../share/' + ChangeFileExt(ExtractFileName(Application.ExeName), '') + '/Schemas') then
    Exit(ExpandFileName(Result + '../share/' + ChangeFileExt(ExtractFileName(Application.ExeName), '') + '/Schemas'));
  {$ENDIF}
  Result := Result + 'Schemas';
end;

procedure TfrmMain.DefinirPathsPadraoNFe;
var
  PastaBase: string;
begin
  PastaBase := PastaDocumentos + 'NFeStudio' + PathDelim;
  ACBrNFe1.Configuracoes.Arquivos.PathSalvar := PastaBase + 'Logs';
  ACBrNFe1.Configuracoes.Arquivos.PathNFe := PastaBase + 'NFe';
  ACBrNFe1.Configuracoes.Arquivos.PathEvento := PastaBase + 'Eventos';
  ACBrNFe1.Configuracoes.Arquivos.PathInu := PastaBase + 'Inutilizacoes';
  ACBrNFe1.Configuracoes.Arquivos.DownloadDFe.PathDownload := PastaBase + 'Downloads';
  ACBrNFe1.Configuracoes.Arquivos.PathSchemas := PastaSchemas;
end;

procedure TfrmMain.CriarPastasNFe;

  procedure CriarPasta(const Pasta: string);
  begin
    // ForceDirectories gera exceção com caminho vazio
    if Pasta <> '' then
      ForceDirectories(Pasta);
  end;

begin
  CriarPasta(ACBrNFe1.Configuracoes.Arquivos.PathSalvar);
  CriarPasta(ACBrNFe1.Configuracoes.Arquivos.PathNFe);
  CriarPasta(ACBrNFe1.Configuracoes.Arquivos.PathEvento);
  CriarPasta(ACBrNFe1.Configuracoes.Arquivos.PathInu);
  CriarPasta(ACBrNFe1.Configuracoes.Arquivos.DownloadDFe.PathDownload);
end;

procedure TfrmMain.GravarConfigPosPrinter(Ini: TCustomIniFile);
begin
  Ini.WriteInteger(SECAO_POSPRINTER, 'Modelo', Ord(ACBrPosPrinter1.Modelo));
  Ini.WriteString(SECAO_POSPRINTER, 'Porta', ACBrPosPrinter1.Porta);
  Ini.WriteString(SECAO_POSPRINTER, 'ParamsDevice', ACBrPosPrinter1.Device.ParamsString);
  Ini.WriteInteger(SECAO_POSPRINTER, 'PaginaDeCodigo', Ord(ACBrPosPrinter1.PaginaDeCodigo));
  Ini.WriteInteger(SECAO_POSPRINTER, 'ColunasFonteNormal', ACBrPosPrinter1.ColunasFonteNormal);
  Ini.WriteInteger(SECAO_POSPRINTER, 'EspacoEntreLinhas', ACBrPosPrinter1.EspacoEntreLinhas);
  Ini.WriteInteger(SECAO_POSPRINTER, 'LinhasEntreCupons', ACBrPosPrinter1.LinhasEntreCupons);
  Ini.WriteBool(SECAO_POSPRINTER, 'CortaPapel', ACBrPosPrinter1.CortaPapel);
  Ini.WriteInteger(SECAO_POSPRINTER, 'TipoCorte', Ord(ACBrPosPrinter1.TipoCorte));
  Ini.WriteBool(SECAO_POSPRINTER, 'TraduzirTags', ACBrPosPrinter1.TraduzirTags);
  Ini.WriteBool(SECAO_POSPRINTER, 'IgnorarTags', ACBrPosPrinter1.IgnorarTags);
  Ini.WriteInteger(SECAO_POSPRINTER, 'LinhasBuffer', ACBrPosPrinter1.LinhasBuffer);
  Ini.WriteBool(SECAO_POSPRINTER, 'ControlePorta', ACBrPosPrinter1.ControlePorta);
  Ini.WriteBool(SECAO_POSPRINTER, 'VerificarImpressora', ACBrPosPrinter1.VerificarImpressora);
  Ini.WriteString(SECAO_POSPRINTER, 'ArqLOG', ACBrPosPrinter1.ArqLOG);
  Ini.WriteBool(SECAO_POSPRINTER, 'Barras.MostrarCodigo', ACBrPosPrinter1.ConfigBarras.MostrarCodigo);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Barras.LarguraLinha', ACBrPosPrinter1.ConfigBarras.LarguraLinha);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Barras.Altura', ACBrPosPrinter1.ConfigBarras.Altura);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Barras.Margem', ACBrPosPrinter1.ConfigBarras.Margem);
  Ini.WriteInteger(SECAO_POSPRINTER, 'QRCode.Tipo', ACBrPosPrinter1.ConfigQRCode.Tipo);
  Ini.WriteInteger(SECAO_POSPRINTER, 'QRCode.LarguraModulo', ACBrPosPrinter1.ConfigQRCode.LarguraModulo);
  Ini.WriteInteger(SECAO_POSPRINTER, 'QRCode.ErrorLevel', ACBrPosPrinter1.ConfigQRCode.ErrorLevel);
  Ini.WriteBool(SECAO_POSPRINTER, 'Logo.IgnorarLogo', ACBrPosPrinter1.ConfigLogo.IgnorarLogo);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Logo.KeyCode1', ACBrPosPrinter1.ConfigLogo.KeyCode1);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Logo.KeyCode2', ACBrPosPrinter1.ConfigLogo.KeyCode2);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Logo.FatorX', ACBrPosPrinter1.ConfigLogo.FatorX);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Logo.FatorY', ACBrPosPrinter1.ConfigLogo.FatorY);
  Ini.WriteBool(SECAO_POSPRINTER, 'Gaveta.SinalInvertido', ACBrPosPrinter1.ConfigGaveta.SinalInvertido);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Gaveta.TempoON', ACBrPosPrinter1.ConfigGaveta.TempoON);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Gaveta.TempoOFF', ACBrPosPrinter1.ConfigGaveta.TempoOFF);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Largura', ACBrPosPrinter1.ConfigModoPagina.Largura);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Altura', ACBrPosPrinter1.ConfigModoPagina.Altura);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Esquerda', ACBrPosPrinter1.ConfigModoPagina.Esquerda);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Topo', ACBrPosPrinter1.ConfigModoPagina.Topo);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Direcao', Ord(ACBrPosPrinter1.ConfigModoPagina.Direcao));
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.EspacoEntreLinhas', ACBrPosPrinter1.ConfigModoPagina.EspacoEntreLinhas);
end;

procedure TfrmMain.LerConfigPosPrinter(Ini: TCustomIniFile);
begin
  // Os valores atuais do componente são usados como padrão para chaves ausentes
  ACBrPosPrinter1.Modelo := TACBrPosPrinterModelo(Ini.ReadInteger(SECAO_POSPRINTER, 'Modelo', Ord(ACBrPosPrinter1.Modelo)));
  ACBrPosPrinter1.Porta := Ini.ReadString(SECAO_POSPRINTER, 'Porta', ACBrPosPrinter1.Porta);
  ACBrPosPrinter1.Device.ParamsString := Ini.ReadString(SECAO_POSPRINTER, 'ParamsDevice', ACBrPosPrinter1.Device.ParamsString);
  ACBrPosPrinter1.PaginaDeCodigo := TACBrPosPaginaCodigo(Ini.ReadInteger(SECAO_POSPRINTER, 'PaginaDeCodigo', Ord(ACBrPosPrinter1.PaginaDeCodigo)));
  ACBrPosPrinter1.ColunasFonteNormal := Ini.ReadInteger(SECAO_POSPRINTER, 'ColunasFonteNormal', ACBrPosPrinter1.ColunasFonteNormal);
  ACBrPosPrinter1.EspacoEntreLinhas := Ini.ReadInteger(SECAO_POSPRINTER, 'EspacoEntreLinhas', ACBrPosPrinter1.EspacoEntreLinhas);
  ACBrPosPrinter1.LinhasEntreCupons := Ini.ReadInteger(SECAO_POSPRINTER, 'LinhasEntreCupons', ACBrPosPrinter1.LinhasEntreCupons);
  ACBrPosPrinter1.CortaPapel := Ini.ReadBool(SECAO_POSPRINTER, 'CortaPapel', ACBrPosPrinter1.CortaPapel);
  ACBrPosPrinter1.TipoCorte := TACBrPosTipoCorte(Ini.ReadInteger(SECAO_POSPRINTER, 'TipoCorte', Ord(ACBrPosPrinter1.TipoCorte)));
  ACBrPosPrinter1.TraduzirTags := Ini.ReadBool(SECAO_POSPRINTER, 'TraduzirTags', ACBrPosPrinter1.TraduzirTags);
  ACBrPosPrinter1.IgnorarTags := Ini.ReadBool(SECAO_POSPRINTER, 'IgnorarTags', ACBrPosPrinter1.IgnorarTags);
  ACBrPosPrinter1.LinhasBuffer := Ini.ReadInteger(SECAO_POSPRINTER, 'LinhasBuffer', ACBrPosPrinter1.LinhasBuffer);
  ACBrPosPrinter1.ControlePorta := Ini.ReadBool(SECAO_POSPRINTER, 'ControlePorta', ACBrPosPrinter1.ControlePorta);
  ACBrPosPrinter1.VerificarImpressora := Ini.ReadBool(SECAO_POSPRINTER, 'VerificarImpressora', ACBrPosPrinter1.VerificarImpressora);
  ACBrPosPrinter1.ArqLOG := Ini.ReadString(SECAO_POSPRINTER, 'ArqLOG', ACBrPosPrinter1.ArqLOG);
  ACBrPosPrinter1.ConfigBarras.MostrarCodigo := Ini.ReadBool(SECAO_POSPRINTER, 'Barras.MostrarCodigo', ACBrPosPrinter1.ConfigBarras.MostrarCodigo);
  ACBrPosPrinter1.ConfigBarras.LarguraLinha := Ini.ReadInteger(SECAO_POSPRINTER, 'Barras.LarguraLinha', ACBrPosPrinter1.ConfigBarras.LarguraLinha);
  ACBrPosPrinter1.ConfigBarras.Altura := Ini.ReadInteger(SECAO_POSPRINTER, 'Barras.Altura', ACBrPosPrinter1.ConfigBarras.Altura);
  ACBrPosPrinter1.ConfigBarras.Margem := Ini.ReadInteger(SECAO_POSPRINTER, 'Barras.Margem', ACBrPosPrinter1.ConfigBarras.Margem);
  ACBrPosPrinter1.ConfigQRCode.Tipo := Ini.ReadInteger(SECAO_POSPRINTER, 'QRCode.Tipo', ACBrPosPrinter1.ConfigQRCode.Tipo);
  ACBrPosPrinter1.ConfigQRCode.LarguraModulo := Ini.ReadInteger(SECAO_POSPRINTER, 'QRCode.LarguraModulo', ACBrPosPrinter1.ConfigQRCode.LarguraModulo);
  ACBrPosPrinter1.ConfigQRCode.ErrorLevel := Ini.ReadInteger(SECAO_POSPRINTER, 'QRCode.ErrorLevel', ACBrPosPrinter1.ConfigQRCode.ErrorLevel);
  ACBrPosPrinter1.ConfigLogo.IgnorarLogo := Ini.ReadBool(SECAO_POSPRINTER, 'Logo.IgnorarLogo', ACBrPosPrinter1.ConfigLogo.IgnorarLogo);
  ACBrPosPrinter1.ConfigLogo.KeyCode1 := Ini.ReadInteger(SECAO_POSPRINTER, 'Logo.KeyCode1', ACBrPosPrinter1.ConfigLogo.KeyCode1);
  ACBrPosPrinter1.ConfigLogo.KeyCode2 := Ini.ReadInteger(SECAO_POSPRINTER, 'Logo.KeyCode2', ACBrPosPrinter1.ConfigLogo.KeyCode2);
  ACBrPosPrinter1.ConfigLogo.FatorX := Ini.ReadInteger(SECAO_POSPRINTER, 'Logo.FatorX', ACBrPosPrinter1.ConfigLogo.FatorX);
  ACBrPosPrinter1.ConfigLogo.FatorY := Ini.ReadInteger(SECAO_POSPRINTER, 'Logo.FatorY', ACBrPosPrinter1.ConfigLogo.FatorY);
  ACBrPosPrinter1.ConfigGaveta.SinalInvertido := Ini.ReadBool(SECAO_POSPRINTER, 'Gaveta.SinalInvertido', ACBrPosPrinter1.ConfigGaveta.SinalInvertido);
  ACBrPosPrinter1.ConfigGaveta.TempoON := Ini.ReadInteger(SECAO_POSPRINTER, 'Gaveta.TempoON', ACBrPosPrinter1.ConfigGaveta.TempoON);
  ACBrPosPrinter1.ConfigGaveta.TempoOFF := Ini.ReadInteger(SECAO_POSPRINTER, 'Gaveta.TempoOFF', ACBrPosPrinter1.ConfigGaveta.TempoOFF);
  ACBrPosPrinter1.ConfigModoPagina.Largura := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Largura', ACBrPosPrinter1.ConfigModoPagina.Largura);
  ACBrPosPrinter1.ConfigModoPagina.Altura := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Altura', ACBrPosPrinter1.ConfigModoPagina.Altura);
  ACBrPosPrinter1.ConfigModoPagina.Esquerda := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Esquerda', ACBrPosPrinter1.ConfigModoPagina.Esquerda);
  ACBrPosPrinter1.ConfigModoPagina.Topo := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Topo', ACBrPosPrinter1.ConfigModoPagina.Topo);
  ACBrPosPrinter1.ConfigModoPagina.Direcao := TACBrPosDirecao(Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Direcao', Ord(ACBrPosPrinter1.ConfigModoPagina.Direcao)));
  ACBrPosPrinter1.ConfigModoPagina.EspacoEntreLinhas := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.EspacoEntreLinhas', ACBrPosPrinter1.ConfigModoPagina.EspacoEntreLinhas);
end;

procedure TfrmMain.SelecionarDANFE(const Componente: string);
begin
  case UpperCase(Componente) of
    DANFE_ESCPOS: ACBrNFe1.DANFE := ACBrNFeDANFeESCPOS1;
    DANFE_FORTES: ACBrNFe1.DANFE := ACBrNFeDANFCeFortes1;
    DANFE_FORTESA4: ACBrNFe1.DANFE := ACBrNFeDANFCeFortesA4_1;
  else
    ACBrNFe1.DANFE := ACBrNFeDANFeRL1;
  end;
end;

procedure TfrmMain.CriarArquivoIni(Ini: TCustomIniFile);
begin
  DefinirPathsPadraoNFe;
  ACBrNFe1.Configuracoes.GravarIni(Ini);
  GravarConfigPosPrinter(Ini);
  Ini.WriteString(SECAO_DANFE, 'Componente', DANFE_RL);
end;

procedure TfrmMain.CarregarConfiguracoes;
var
  ArqIni: string;
  Ini: TIniFile;
begin
  ArqIni := ArquivoIni;
  ForceDirectories(ExtractFilePath(ArqIni));
  Ini := TIniFile.Create(ArqIni);
  try
    if not FileExists(ArqIni) then
      CriarArquivoIni(Ini);
    ACBrNFe1.Configuracoes.LerIni(Ini);
    LerConfigPosPrinter(Ini);
    SelecionarDANFE(Ini.ReadString(SECAO_DANFE, 'Componente', DANFE_RL));
  finally
    Ini.Free;
  end;
  CriarPastasNFe;
end;

procedure TfrmMain.InicializarBanco;
begin
  ZConnection1.Connect;
  dmdNFe.CriarTabelas;
end;

procedure TfrmMain.ImprimirDANFE(const Chave: string);
var
  XML: string;
  Modelo: integer;
  Tipo: TTipoDANFE;
  DANFEConfigurada: TACBrDFeDANFeReport;
begin
  // XML importado sem nfeProc (somente assinado) sairia como "não enviada para SEFAZ"
  Screen.Cursor := crHourGlass;
  try
    try
      ProcessadorNFe.AtualizarProtocolo(Chave);
    finally
      Screen.Cursor := crDefault;
    end;
  except
    on E: Exception do
      MessageDlg(Format(MSG_ERRO_CONSULTA, [Chave, E.Message]), mtWarning, [mbOK], 0);
  end;

  XML := dmdNFe.ObterXMLNFe(Chave);
  if XML = '' then
    raise Exception.CreateFmt(MSG_SEM_XML, [Chave]);
  ACBrNFe1.NotasFiscais.Clear;
  try
    ACBrNFe1.NotasFiscais.LoadFromString(XML);
    Modelo := ACBrNFe1.NotasFiscais[0].NFe.Ide.modelo;
    if not TfrmImprimirDANFE.Selecionar(Modelo, TipoDANFEPadrao, Tipo) then
      Exit;
    // troca temporária: a DANFE das configurações continua sendo a padrão do ACBrNFe1
    DANFEConfigurada := ACBrNFe1.DANFE;
    try
      ACBrNFe1.DANFE := ComponenteDANFE(Tipo, Modelo);
      ACBrNFe1.NotasFiscais.Imprimir;
    finally
      ACBrNFe1.DANFE := DANFEConfigurada;
    end;
  finally
    ACBrNFe1.NotasFiscais.Clear;
  end;
end;

function TfrmMain.TipoDANFEPadrao: TTipoDANFE;
begin
  // ACBrNFe1.DANFE é definido por SelecionarDANFE a partir de [DANFE] Componente
  if ACBrNFe1.DANFE = ACBrNFeDANFeESCPOS1 then
    Result := tdPOS
  else if ACBrNFe1.DANFE = ACBrNFeDANFCeFortes1 then
    Result := tdBobina
  else
    Result := tdA4;
end;

function TfrmMain.ComponenteDANFE(Tipo: TTipoDANFE; Modelo: integer): TACBrDFeDANFeReport;
begin
  case Tipo of
    tdPOS: Result := ACBrNFeDANFeESCPOS1;
    tdBobina: Result := ACBrNFeDANFCeFortes1;
  else
    // em A4 a NFC-e usa o layout de DANFCe; o DANFE RL é exclusivo da NF-e
    if Modelo = MODELO_NFCE then
      Result := ACBrNFeDANFCeFortesA4_1
    else
      Result := ACBrNFeDANFeRL1;
  end;
end;

procedure TfrmMain.AjustarPeriodoFiltro;
var
  DataInicial, DataFinal: TDateTime;
begin
  if not dmdNFe.ObterPeriodoNFeCab(DataInicial, DataFinal) then
    Exit;
  dtpInicial.Date := DataInicial;
  dtpFinal.Date := DataFinal;
  btnFiltrarClick(btnFiltrar);
end;

end.

