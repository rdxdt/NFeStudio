unit ufrmconfig;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Spin, EditBtn, IniFiles, ACBrNFe;

type

  { TfrmConfig }

  TfrmConfig = class(TForm)
    pgcConfig: TPageControl;
    tabGeral: TTabSheet;
    sbxGeral: TScrollBox;
    grpGeralDocumento: TGroupBox;
    lblModeloDF: TLabel;
    cbxModeloDF: TComboBox;
    lblVersaoDF: TLabel;
    cbxVersaoDF: TComboBox;
    lblFormaEmissao: TLabel;
    cbxFormaEmissao: TComboBox;
    lblVersaoQRCode: TLabel;
    cbxVersaoQRCode: TComboBox;
    lblIdCSC: TLabel;
    edtIdCSC: TEdit;
    lblCSC: TLabel;
    edtCSC: TEdit;
    lblForcarGerarTagRejeicao938: TLabel;
    cbxForcarGerarTagRejeicao938: TComboBox;
    lblForcarGerarTagRejeicao906: TLabel;
    cbxForcarGerarTagRejeicao906: TComboBox;
    lblFormatoAlerta: TLabel;
    edtFormatoAlerta: TEdit;
    grpGeralBibliotecasSSL: TGroupBox;
    lblSSLCryptLib: TLabel;
    cbxSSLCryptLib: TComboBox;
    lblSSLHttpLib: TLabel;
    cbxSSLHttpLib: TComboBox;
    lblSSLXmlSignLib: TLabel;
    cbxSSLXmlSignLib: TComboBox;
    grpGeralOpcoes: TGroupBox;
    chkSalvarGer: TCheckBox;
    chkExibirErroSchema: TCheckBox;
    chkRetirarAcentos: TCheckBox;
    chkRetirarEspacos: TCheckBox;
    chkIdentarXML: TCheckBox;
    chkValidarDigest: TCheckBox;
    chkAtualizarXMLCancelado: TCheckBox;
    chkCamposFatObrigatorios: TCheckBox;
    tabWebServices: TTabSheet;
    sbxWebServices: TScrollBox;
    grpWebServices: TGroupBox;
    lblUF: TLabel;
    cbxUF: TComboBox;
    lblAmbiente: TLabel;
    cbxAmbiente: TComboBox;
    lblSSLType: TLabel;
    cbxSSLType: TComboBox;
    lblTimeOut: TLabel;
    speTimeOut: TSpinEdit;
    lblAguardarConsultaRet: TLabel;
    speAguardarConsultaRet: TSpinEdit;
    lblIntervaloTentativas: TLabel;
    speIntervaloTentativas: TSpinEdit;
    lblTentativas: TLabel;
    speTentativas: TSpinEdit;
    lblQuebradeLinha: TLabel;
    edtQuebradeLinha: TEdit;
    lblTimeZoneModo: TLabel;
    cbxTimeZoneModo: TComboBox;
    lblTimeZoneStr: TLabel;
    edtTimeZoneStr: TEdit;
    grpWebServicesOpcoes: TGroupBox;
    chkSalvarWS: TCheckBox;
    chkVisualizar: TCheckBox;
    chkTimeOutPorThread: TCheckBox;
    chkAjustaAguardaConsultaRet: TCheckBox;
    grpWebServicesProxy: TGroupBox;
    lblProxyHost: TLabel;
    edtProxyHost: TEdit;
    lblProxyPort: TLabel;
    edtProxyPort: TEdit;
    lblProxyUser: TLabel;
    edtProxyUser: TEdit;
    lblProxyPass: TLabel;
    edtProxyPass: TEdit;
    tabCertificado: TTabSheet;
    sbxCertificado: TScrollBox;
    grpCertificadoCertificadoDigital: TGroupBox;
    lblArquivoPFX: TLabel;
    edtArquivoPFX: TFileNameEdit;
    lblURLPFX: TLabel;
    edtURLPFX: TEdit;
    lblSenha: TLabel;
    edtSenha: TEdit;
    lblNumeroSerie: TLabel;
    edtNumeroSerie: TEdit;
    lblVerificarValidade: TLabel;
    chkVerificarValidade: TCheckBox;
    grpCertificadoResponsavelTecnico: TGroupBox;
    lblIdCSRT: TLabel;
    speIdCSRT: TSpinEdit;
    lblCSRT: TLabel;
    edtCSRT: TEdit;
    tabArquivos: TTabSheet;
    sbxArquivos: TScrollBox;
    grpArquivosPastas: TGroupBox;
    lblPathSalvar: TLabel;
    edtPathSalvar: TDirectoryEdit;
    lblPathSchemas: TLabel;
    edtPathSchemas: TDirectoryEdit;
    lblPathNFe: TLabel;
    edtPathNFe: TDirectoryEdit;
    lblPathEvento: TLabel;
    edtPathEvento: TDirectoryEdit;
    lblPathInu: TLabel;
    edtPathInu: TDirectoryEdit;
    lblPathDownload: TLabel;
    edtPathDownload: TDirectoryEdit;
    lblIniServicos: TLabel;
    edtIniServicos: TFileNameEdit;
    lblPathArquivoMunicipios: TLabel;
    edtPathArquivoMunicipios: TFileNameEdit;
    grpArquivosOpcoes: TGroupBox;
    chkSalvarArq: TCheckBox;
    chkAdicionarLiteral: TCheckBox;
    chkSepararPorCNPJ: TCheckBox;
    chkSepararPorIE: TCheckBox;
    chkSepararPorModelo: TCheckBox;
    chkSepararPorAno: TCheckBox;
    chkSepararPorMes: TCheckBox;
    chkSepararPorDia: TCheckBox;
    chkSepararPorNome: TCheckBox;
    chkSalvarEvento: TCheckBox;
    chkSalvarApenasNFeProcessadas: TCheckBox;
    chkEmissaoPathNFe: TCheckBox;
    chkNormatizarMunicipios: TCheckBox;
    tabPosPrinter: TTabSheet;
    sbxPosPrinter: TScrollBox;
    grpPosPrinterImpressora: TGroupBox;
    lblPosModelo: TLabel;
    cbxPosModelo: TComboBox;
    lblPosPorta: TLabel;
    edtPosPorta: TEdit;
    lblPosParamsDevice: TLabel;
    edtPosParamsDevice: TEdit;
    lblPosPaginaDeCodigo: TLabel;
    cbxPosPaginaDeCodigo: TComboBox;
    lblPosColunasFonteNormal: TLabel;
    spePosColunasFonteNormal: TSpinEdit;
    lblPosEspacoEntreLinhas: TLabel;
    spePosEspacoEntreLinhas: TSpinEdit;
    lblPosLinhasEntreCupons: TLabel;
    spePosLinhasEntreCupons: TSpinEdit;
    lblPosTipoCorte: TLabel;
    cbxPosTipoCorte: TComboBox;
    lblPosLinhasBuffer: TLabel;
    spePosLinhasBuffer: TSpinEdit;
    lblPosArqLOG: TLabel;
    edtPosArqLOG: TFileNameEdit;
    grpPosPrinterOpcoes: TGroupBox;
    chkPosCortaPapel: TCheckBox;
    chkPosTraduzirTags: TCheckBox;
    chkPosIgnorarTags: TCheckBox;
    chkPosControlePorta: TCheckBox;
    chkPosVerificarImpressora: TCheckBox;
    grpPosPrinterCodigoDeBarras: TGroupBox;
    lblBarrasMostrarCodigo: TLabel;
    chkBarrasMostrarCodigo: TCheckBox;
    lblBarrasLarguraLinha: TLabel;
    speBarrasLarguraLinha: TSpinEdit;
    lblBarrasAltura: TLabel;
    speBarrasAltura: TSpinEdit;
    lblBarrasMargem: TLabel;
    speBarrasMargem: TSpinEdit;
    grpPosPrinterQRCode: TGroupBox;
    lblQRCodeTipo: TLabel;
    speQRCodeTipo: TSpinEdit;
    lblQRCodeLarguraModulo: TLabel;
    speQRCodeLarguraModulo: TSpinEdit;
    lblQRCodeErrorLevel: TLabel;
    speQRCodeErrorLevel: TSpinEdit;
    grpPosPrinterLogotipo: TGroupBox;
    lblLogoIgnorarLogo: TLabel;
    chkLogoIgnorarLogo: TCheckBox;
    lblLogoKeyCode1: TLabel;
    speLogoKeyCode1: TSpinEdit;
    lblLogoKeyCode2: TLabel;
    speLogoKeyCode2: TSpinEdit;
    lblLogoFatorX: TLabel;
    speLogoFatorX: TSpinEdit;
    lblLogoFatorY: TLabel;
    speLogoFatorY: TSpinEdit;
    grpPosPrinterGaveta: TGroupBox;
    lblGavetaSinalInvertido: TLabel;
    chkGavetaSinalInvertido: TCheckBox;
    lblGavetaTempoON: TLabel;
    speGavetaTempoON: TSpinEdit;
    lblGavetaTempoOFF: TLabel;
    speGavetaTempoOFF: TSpinEdit;
    grpPosPrinterModoPagina: TGroupBox;
    lblModoPaginaLargura: TLabel;
    speModoPaginaLargura: TSpinEdit;
    lblModoPaginaAltura: TLabel;
    speModoPaginaAltura: TSpinEdit;
    lblModoPaginaEsquerda: TLabel;
    speModoPaginaEsquerda: TSpinEdit;
    lblModoPaginaTopo: TLabel;
    speModoPaginaTopo: TSpinEdit;
    lblModoPaginaDirecao: TLabel;
    cbxModoPaginaDirecao: TComboBox;
    lblModoPaginaEspacoEntreLinhas: TLabel;
    speModoPaginaEspacoEntreLinhas: TSpinEdit;
    tabDANFE: TTabSheet;
    sbxDANFE: TScrollBox;
    grpDANFE: TGroupBox;
    lblDANFE: TLabel;
    cbxDANFE: TComboBox;
    pnlBotoes: TPanel;
    btnCancelar: TButton;
    btnSalvar: TButton;
    ACBrNFe1: TACBrNFe;
    procedure btnSalvarClick(Sender: TObject);
  private
    FArquivoIni: string;
    procedure CarregarGeral;
    procedure SalvarGeral;
    procedure CarregarWebServices;
    procedure SalvarWebServices;
    procedure CarregarCertificado;
    procedure SalvarCertificado;
    procedure CarregarArquivos;
    procedure SalvarArquivos;
    procedure CarregarPosPrinter(Ini: TCustomIniFile);
    procedure SalvarPosPrinter(Ini: TCustomIniFile);
    procedure CarregarDANFE(Ini: TCustomIniFile);
    procedure SalvarDANFE(Ini: TCustomIniFile);
    procedure CarregarIni;
    procedure SalvarIni;
  public
    class function Executar(const ArquivoIni: string): Boolean;
  end;

var
  frmConfig: TfrmConfig;

implementation

uses
  StrUtils, blcksock, ACBrDFeSSL, ACBrUtil.DateTime, pcnConversao, pcnConversaoNFe;

{$R *.lfm}

const
  // Mesmas seções/chaves gravadas pelo ufrmmain
  SECAO_DANFE = 'DANFE';
  SECAO_POSPRINTER = 'PosPrinter';
  // Ordem igual aos itens de cbxDANFE
  DANFE_CODIGOS: array[0..3] of string = ('RL', 'ESCPOS', 'FORTES', 'FORTESA4');

{ TfrmConfig }

class function TfrmConfig.Executar(const ArquivoIni: string): Boolean;
begin
  frmConfig := TfrmConfig.Create(Application);
  try
    frmConfig.FArquivoIni := ArquivoIni;
    frmConfig.CarregarIni;
    Result := frmConfig.ShowModal = mrOK;
  finally
    FreeAndNil(frmConfig);
  end;
end;

procedure TfrmConfig.btnSalvarClick(Sender: TObject);
begin
  SalvarIni;
  ModalResult := mrOK;
end;

procedure TfrmConfig.CarregarIni;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FArquivoIni);
  try
    // As seções do ACBrNFe são lidas pelo próprio ACBr, mantendo o mesmo formato
    // (inclusive senhas codificadas) usado pelo frmMain
    ACBrNFe1.Configuracoes.LerIni(Ini);
    CarregarGeral;
    CarregarWebServices;
    CarregarCertificado;
    CarregarArquivos;
    CarregarPosPrinter(Ini);
    CarregarDANFE(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TfrmConfig.SalvarIni;
var
  Ini: TIniFile;
begin
  SalvarGeral;
  SalvarWebServices;
  SalvarCertificado;
  SalvarArquivos;
  Ini := TIniFile.Create(FArquivoIni);
  try
    ACBrNFe1.Configuracoes.GravarIni(Ini);
    SalvarPosPrinter(Ini);
    SalvarDANFE(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TfrmConfig.CarregarGeral;
begin
  cbxModeloDF.ItemIndex := Ord(ACBrNFe1.Configuracoes.Geral.ModeloDF);
  cbxVersaoDF.ItemIndex := Ord(ACBrNFe1.Configuracoes.Geral.VersaoDF);
  cbxFormaEmissao.ItemIndex := Ord(ACBrNFe1.Configuracoes.Geral.FormaEmissao);
  cbxVersaoQRCode.ItemIndex := Ord(ACBrNFe1.Configuracoes.Geral.VersaoQRCode);
  edtIdCSC.Text := ACBrNFe1.Configuracoes.Geral.IdCSC;
  edtCSC.Text := ACBrNFe1.Configuracoes.Geral.CSC;
  cbxForcarGerarTagRejeicao938.ItemIndex := Ord(ACBrNFe1.Configuracoes.Geral.ForcarGerarTagRejeicao938);
  cbxForcarGerarTagRejeicao906.ItemIndex := Ord(ACBrNFe1.Configuracoes.Geral.ForcarGerarTagRejeicao906);
  edtFormatoAlerta.Text := ACBrNFe1.Configuracoes.Geral.FormatoAlerta;
  cbxSSLCryptLib.ItemIndex := Ord(ACBrNFe1.Configuracoes.Geral.SSLCryptLib);
  cbxSSLHttpLib.ItemIndex := Ord(ACBrNFe1.Configuracoes.Geral.SSLHttpLib);
  cbxSSLXmlSignLib.ItemIndex := Ord(ACBrNFe1.Configuracoes.Geral.SSLXmlSignLib);
  chkSalvarGer.Checked := ACBrNFe1.Configuracoes.Geral.Salvar;
  chkExibirErroSchema.Checked := ACBrNFe1.Configuracoes.Geral.ExibirErroSchema;
  chkRetirarAcentos.Checked := ACBrNFe1.Configuracoes.Geral.RetirarAcentos;
  chkRetirarEspacos.Checked := ACBrNFe1.Configuracoes.Geral.RetirarEspacos;
  chkIdentarXML.Checked := ACBrNFe1.Configuracoes.Geral.IdentarXML;
  chkValidarDigest.Checked := ACBrNFe1.Configuracoes.Geral.ValidarDigest;
  chkAtualizarXMLCancelado.Checked := ACBrNFe1.Configuracoes.Geral.AtualizarXMLCancelado;
  chkCamposFatObrigatorios.Checked := ACBrNFe1.Configuracoes.Geral.CamposFatObrigatorios;
end;

procedure TfrmConfig.SalvarGeral;
begin
  ACBrNFe1.Configuracoes.Geral.ModeloDF := TpcnModeloDF(cbxModeloDF.ItemIndex);
  ACBrNFe1.Configuracoes.Geral.VersaoDF := TpcnVersaoDF(cbxVersaoDF.ItemIndex);
  ACBrNFe1.Configuracoes.Geral.FormaEmissao := TpcnTipoEmissao(cbxFormaEmissao.ItemIndex);
  ACBrNFe1.Configuracoes.Geral.VersaoQRCode := TpcnVersaoQrCode(cbxVersaoQRCode.ItemIndex);
  ACBrNFe1.Configuracoes.Geral.IdCSC := edtIdCSC.Text;
  ACBrNFe1.Configuracoes.Geral.CSC := edtCSC.Text;
  ACBrNFe1.Configuracoes.Geral.ForcarGerarTagRejeicao938 := TForcarGeracaoTag(cbxForcarGerarTagRejeicao938.ItemIndex);
  ACBrNFe1.Configuracoes.Geral.ForcarGerarTagRejeicao906 := TForcarGeracaoTag(cbxForcarGerarTagRejeicao906.ItemIndex);
  ACBrNFe1.Configuracoes.Geral.FormatoAlerta := edtFormatoAlerta.Text;
  ACBrNFe1.Configuracoes.Geral.SSLCryptLib := TSSLCryptLib(cbxSSLCryptLib.ItemIndex);
  ACBrNFe1.Configuracoes.Geral.SSLHttpLib := TSSLHttpLib(cbxSSLHttpLib.ItemIndex);
  ACBrNFe1.Configuracoes.Geral.SSLXmlSignLib := TSSLXmlSignLib(cbxSSLXmlSignLib.ItemIndex);
  ACBrNFe1.Configuracoes.Geral.Salvar := chkSalvarGer.Checked;
  ACBrNFe1.Configuracoes.Geral.ExibirErroSchema := chkExibirErroSchema.Checked;
  ACBrNFe1.Configuracoes.Geral.RetirarAcentos := chkRetirarAcentos.Checked;
  ACBrNFe1.Configuracoes.Geral.RetirarEspacos := chkRetirarEspacos.Checked;
  ACBrNFe1.Configuracoes.Geral.IdentarXML := chkIdentarXML.Checked;
  ACBrNFe1.Configuracoes.Geral.ValidarDigest := chkValidarDigest.Checked;
  ACBrNFe1.Configuracoes.Geral.AtualizarXMLCancelado := chkAtualizarXMLCancelado.Checked;
  ACBrNFe1.Configuracoes.Geral.CamposFatObrigatorios := chkCamposFatObrigatorios.Checked;
end;

procedure TfrmConfig.CarregarWebServices;
begin
  cbxUF.ItemIndex := cbxUF.Items.IndexOf(ACBrNFe1.Configuracoes.WebServices.UF);
  cbxAmbiente.ItemIndex := Ord(ACBrNFe1.Configuracoes.WebServices.Ambiente);
  cbxSSLType.ItemIndex := Ord(ACBrNFe1.Configuracoes.WebServices.SSLType);
  speTimeOut.Value := ACBrNFe1.Configuracoes.WebServices.TimeOut;
  speAguardarConsultaRet.Value := ACBrNFe1.Configuracoes.WebServices.AguardarConsultaRet;
  speIntervaloTentativas.Value := ACBrNFe1.Configuracoes.WebServices.IntervaloTentativas;
  speTentativas.Value := ACBrNFe1.Configuracoes.WebServices.Tentativas;
  edtQuebradeLinha.Text := ACBrNFe1.Configuracoes.WebServices.QuebradeLinha;
  cbxTimeZoneModo.ItemIndex := Ord(ACBrNFe1.Configuracoes.WebServices.TimeZoneConf.ModoDeteccao);
  edtTimeZoneStr.Text := ACBrNFe1.Configuracoes.WebServices.TimeZoneConf.TimeZoneStr;
  chkSalvarWS.Checked := ACBrNFe1.Configuracoes.WebServices.Salvar;
  chkVisualizar.Checked := ACBrNFe1.Configuracoes.WebServices.Visualizar;
  chkTimeOutPorThread.Checked := ACBrNFe1.Configuracoes.WebServices.TimeOutPorThread;
  chkAjustaAguardaConsultaRet.Checked := ACBrNFe1.Configuracoes.WebServices.AjustaAguardaConsultaRet;
  edtProxyHost.Text := ACBrNFe1.Configuracoes.WebServices.ProxyHost;
  edtProxyPort.Text := ACBrNFe1.Configuracoes.WebServices.ProxyPort;
  edtProxyUser.Text := ACBrNFe1.Configuracoes.WebServices.ProxyUser;
  edtProxyPass.Text := ACBrNFe1.Configuracoes.WebServices.ProxyPass;
end;

procedure TfrmConfig.SalvarWebServices;
begin
  ACBrNFe1.Configuracoes.WebServices.UF := cbxUF.Text;
  ACBrNFe1.Configuracoes.WebServices.Ambiente := TpcnTipoAmbiente(cbxAmbiente.ItemIndex);
  ACBrNFe1.Configuracoes.WebServices.SSLType := TSSLType(cbxSSLType.ItemIndex);
  ACBrNFe1.Configuracoes.WebServices.TimeOut := speTimeOut.Value;
  ACBrNFe1.Configuracoes.WebServices.AguardarConsultaRet := speAguardarConsultaRet.Value;
  ACBrNFe1.Configuracoes.WebServices.IntervaloTentativas := speIntervaloTentativas.Value;
  ACBrNFe1.Configuracoes.WebServices.Tentativas := speTentativas.Value;
  ACBrNFe1.Configuracoes.WebServices.QuebradeLinha := edtQuebradeLinha.Text;
  ACBrNFe1.Configuracoes.WebServices.TimeZoneConf.ModoDeteccao := TTimeZoneModoDeteccao(cbxTimeZoneModo.ItemIndex);
  ACBrNFe1.Configuracoes.WebServices.TimeZoneConf.TimeZoneStr := edtTimeZoneStr.Text;
  ACBrNFe1.Configuracoes.WebServices.Salvar := chkSalvarWS.Checked;
  ACBrNFe1.Configuracoes.WebServices.Visualizar := chkVisualizar.Checked;
  ACBrNFe1.Configuracoes.WebServices.TimeOutPorThread := chkTimeOutPorThread.Checked;
  ACBrNFe1.Configuracoes.WebServices.AjustaAguardaConsultaRet := chkAjustaAguardaConsultaRet.Checked;
  ACBrNFe1.Configuracoes.WebServices.ProxyHost := edtProxyHost.Text;
  ACBrNFe1.Configuracoes.WebServices.ProxyPort := edtProxyPort.Text;
  ACBrNFe1.Configuracoes.WebServices.ProxyUser := edtProxyUser.Text;
  ACBrNFe1.Configuracoes.WebServices.ProxyPass := edtProxyPass.Text;
end;

procedure TfrmConfig.CarregarCertificado;
begin
  edtArquivoPFX.Text := ACBrNFe1.Configuracoes.Certificados.ArquivoPFX;
  edtURLPFX.Text := ACBrNFe1.Configuracoes.Certificados.URLPFX;
  edtSenha.Text := ACBrNFe1.Configuracoes.Certificados.Senha;
  edtNumeroSerie.Text := ACBrNFe1.Configuracoes.Certificados.NumeroSerie;
  chkVerificarValidade.Checked := ACBrNFe1.Configuracoes.Certificados.VerificarValidade;
  speIdCSRT.Value := ACBrNFe1.Configuracoes.RespTec.IdCSRT;
  edtCSRT.Text := ACBrNFe1.Configuracoes.RespTec.CSRT;
end;

procedure TfrmConfig.SalvarCertificado;
begin
  ACBrNFe1.Configuracoes.Certificados.ArquivoPFX := edtArquivoPFX.Text;
  ACBrNFe1.Configuracoes.Certificados.URLPFX := edtURLPFX.Text;
  ACBrNFe1.Configuracoes.Certificados.Senha := edtSenha.Text;
  ACBrNFe1.Configuracoes.Certificados.NumeroSerie := edtNumeroSerie.Text;
  ACBrNFe1.Configuracoes.Certificados.VerificarValidade := chkVerificarValidade.Checked;
  ACBrNFe1.Configuracoes.RespTec.IdCSRT := speIdCSRT.Value;
  ACBrNFe1.Configuracoes.RespTec.CSRT := edtCSRT.Text;
end;

procedure TfrmConfig.CarregarArquivos;
begin
  edtPathSalvar.Text := ACBrNFe1.Configuracoes.Arquivos.PathSalvar;
  edtPathSchemas.Text := ACBrNFe1.Configuracoes.Arquivos.PathSchemas;
  edtPathNFe.Text := ACBrNFe1.Configuracoes.Arquivos.PathNFe;
  edtPathEvento.Text := ACBrNFe1.Configuracoes.Arquivos.PathEvento;
  edtPathInu.Text := ACBrNFe1.Configuracoes.Arquivos.PathInu;
  edtPathDownload.Text := ACBrNFe1.Configuracoes.Arquivos.DownloadDFe.PathDownload;
  edtIniServicos.Text := ACBrNFe1.Configuracoes.Arquivos.IniServicos;
  edtPathArquivoMunicipios.Text := ACBrNFe1.Configuracoes.Arquivos.PathArquivoMunicipios;
  chkSalvarArq.Checked := ACBrNFe1.Configuracoes.Arquivos.Salvar;
  chkAdicionarLiteral.Checked := ACBrNFe1.Configuracoes.Arquivos.AdicionarLiteral;
  chkSepararPorCNPJ.Checked := ACBrNFe1.Configuracoes.Arquivos.SepararPorCNPJ;
  chkSepararPorIE.Checked := ACBrNFe1.Configuracoes.Arquivos.SepararPorIE;
  chkSepararPorModelo.Checked := ACBrNFe1.Configuracoes.Arquivos.SepararPorModelo;
  chkSepararPorAno.Checked := ACBrNFe1.Configuracoes.Arquivos.SepararPorAno;
  chkSepararPorMes.Checked := ACBrNFe1.Configuracoes.Arquivos.SepararPorMes;
  chkSepararPorDia.Checked := ACBrNFe1.Configuracoes.Arquivos.SepararPorDia;
  chkSepararPorNome.Checked := ACBrNFe1.Configuracoes.Arquivos.DownloadDFe.SepararPorNome;
  chkSalvarEvento.Checked := ACBrNFe1.Configuracoes.Arquivos.SalvarEvento;
  chkSalvarApenasNFeProcessadas.Checked := ACBrNFe1.Configuracoes.Arquivos.SalvarApenasNFeProcessadas;
  chkEmissaoPathNFe.Checked := ACBrNFe1.Configuracoes.Arquivos.EmissaoPathNFe;
  chkNormatizarMunicipios.Checked := ACBrNFe1.Configuracoes.Arquivos.NormatizarMunicipios;
end;

procedure TfrmConfig.SalvarArquivos;
begin
  ACBrNFe1.Configuracoes.Arquivos.PathSalvar := edtPathSalvar.Text;
  ACBrNFe1.Configuracoes.Arquivos.PathSchemas := edtPathSchemas.Text;
  ACBrNFe1.Configuracoes.Arquivos.PathNFe := edtPathNFe.Text;
  ACBrNFe1.Configuracoes.Arquivos.PathEvento := edtPathEvento.Text;
  ACBrNFe1.Configuracoes.Arquivos.PathInu := edtPathInu.Text;
  ACBrNFe1.Configuracoes.Arquivos.DownloadDFe.PathDownload := edtPathDownload.Text;
  ACBrNFe1.Configuracoes.Arquivos.IniServicos := edtIniServicos.Text;
  ACBrNFe1.Configuracoes.Arquivos.PathArquivoMunicipios := edtPathArquivoMunicipios.Text;
  ACBrNFe1.Configuracoes.Arquivos.Salvar := chkSalvarArq.Checked;
  ACBrNFe1.Configuracoes.Arquivos.AdicionarLiteral := chkAdicionarLiteral.Checked;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorCNPJ := chkSepararPorCNPJ.Checked;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorIE := chkSepararPorIE.Checked;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorModelo := chkSepararPorModelo.Checked;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorAno := chkSepararPorAno.Checked;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorMes := chkSepararPorMes.Checked;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorDia := chkSepararPorDia.Checked;
  ACBrNFe1.Configuracoes.Arquivos.DownloadDFe.SepararPorNome := chkSepararPorNome.Checked;
  ACBrNFe1.Configuracoes.Arquivos.SalvarEvento := chkSalvarEvento.Checked;
  ACBrNFe1.Configuracoes.Arquivos.SalvarApenasNFeProcessadas := chkSalvarApenasNFeProcessadas.Checked;
  ACBrNFe1.Configuracoes.Arquivos.EmissaoPathNFe := chkEmissaoPathNFe.Checked;
  ACBrNFe1.Configuracoes.Arquivos.NormatizarMunicipios := chkNormatizarMunicipios.Checked;
end;

procedure TfrmConfig.CarregarPosPrinter(Ini: TCustomIniFile);
begin
  cbxPosModelo.ItemIndex := Ini.ReadInteger(SECAO_POSPRINTER, 'Modelo', 0);
  edtPosPorta.Text := Ini.ReadString(SECAO_POSPRINTER, 'Porta', '');
  edtPosParamsDevice.Text := Ini.ReadString(SECAO_POSPRINTER, 'ParamsDevice', '');
  cbxPosPaginaDeCodigo.ItemIndex := Ini.ReadInteger(SECAO_POSPRINTER, 'PaginaDeCodigo', 2);
  spePosColunasFonteNormal.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'ColunasFonteNormal', 48);
  spePosEspacoEntreLinhas.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'EspacoEntreLinhas', 0);
  spePosLinhasEntreCupons.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'LinhasEntreCupons', 0);
  cbxPosTipoCorte.ItemIndex := Ini.ReadInteger(SECAO_POSPRINTER, 'TipoCorte', 0);
  spePosLinhasBuffer.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'LinhasBuffer', 0);
  edtPosArqLOG.Text := Ini.ReadString(SECAO_POSPRINTER, 'ArqLOG', '');
  chkPosCortaPapel.Checked := Ini.ReadBool(SECAO_POSPRINTER, 'CortaPapel', True);
  chkPosTraduzirTags.Checked := Ini.ReadBool(SECAO_POSPRINTER, 'TraduzirTags', True);
  chkPosIgnorarTags.Checked := Ini.ReadBool(SECAO_POSPRINTER, 'IgnorarTags', False);
  chkPosControlePorta.Checked := Ini.ReadBool(SECAO_POSPRINTER, 'ControlePorta', False);
  chkPosVerificarImpressora.Checked := Ini.ReadBool(SECAO_POSPRINTER, 'VerificarImpressora', False);
  chkBarrasMostrarCodigo.Checked := Ini.ReadBool(SECAO_POSPRINTER, 'Barras.MostrarCodigo', False);
  speBarrasLarguraLinha.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'Barras.LarguraLinha', 0);
  speBarrasAltura.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'Barras.Altura', 0);
  speBarrasMargem.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'Barras.Margem', 0);
  speQRCodeTipo.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'QRCode.Tipo', 2);
  speQRCodeLarguraModulo.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'QRCode.LarguraModulo', 4);
  speQRCodeErrorLevel.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'QRCode.ErrorLevel', 0);
  chkLogoIgnorarLogo.Checked := Ini.ReadBool(SECAO_POSPRINTER, 'Logo.IgnorarLogo', False);
  speLogoKeyCode1.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'Logo.KeyCode1', 32);
  speLogoKeyCode2.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'Logo.KeyCode2', 32);
  speLogoFatorX.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'Logo.FatorX', 1);
  speLogoFatorY.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'Logo.FatorY', 1);
  chkGavetaSinalInvertido.Checked := Ini.ReadBool(SECAO_POSPRINTER, 'Gaveta.SinalInvertido', False);
  speGavetaTempoON.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'Gaveta.TempoON', 50);
  speGavetaTempoOFF.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'Gaveta.TempoOFF', 200);
  speModoPaginaLargura.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Largura', 0);
  speModoPaginaAltura.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Altura', 0);
  speModoPaginaEsquerda.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Esquerda', 0);
  speModoPaginaTopo.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Topo', 0);
  cbxModoPaginaDirecao.ItemIndex := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.Direcao', 0);
  speModoPaginaEspacoEntreLinhas.Value := Ini.ReadInteger(SECAO_POSPRINTER, 'ModoPagina.EspacoEntreLinhas', 0);
end;

procedure TfrmConfig.SalvarPosPrinter(Ini: TCustomIniFile);
begin
  Ini.WriteInteger(SECAO_POSPRINTER, 'Modelo', cbxPosModelo.ItemIndex);
  Ini.WriteString(SECAO_POSPRINTER, 'Porta', edtPosPorta.Text);
  Ini.WriteString(SECAO_POSPRINTER, 'ParamsDevice', edtPosParamsDevice.Text);
  Ini.WriteInteger(SECAO_POSPRINTER, 'PaginaDeCodigo', cbxPosPaginaDeCodigo.ItemIndex);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ColunasFonteNormal', spePosColunasFonteNormal.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'EspacoEntreLinhas', spePosEspacoEntreLinhas.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'LinhasEntreCupons', spePosLinhasEntreCupons.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'TipoCorte', cbxPosTipoCorte.ItemIndex);
  Ini.WriteInteger(SECAO_POSPRINTER, 'LinhasBuffer', spePosLinhasBuffer.Value);
  Ini.WriteString(SECAO_POSPRINTER, 'ArqLOG', edtPosArqLOG.Text);
  Ini.WriteBool(SECAO_POSPRINTER, 'CortaPapel', chkPosCortaPapel.Checked);
  Ini.WriteBool(SECAO_POSPRINTER, 'TraduzirTags', chkPosTraduzirTags.Checked);
  Ini.WriteBool(SECAO_POSPRINTER, 'IgnorarTags', chkPosIgnorarTags.Checked);
  Ini.WriteBool(SECAO_POSPRINTER, 'ControlePorta', chkPosControlePorta.Checked);
  Ini.WriteBool(SECAO_POSPRINTER, 'VerificarImpressora', chkPosVerificarImpressora.Checked);
  Ini.WriteBool(SECAO_POSPRINTER, 'Barras.MostrarCodigo', chkBarrasMostrarCodigo.Checked);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Barras.LarguraLinha', speBarrasLarguraLinha.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Barras.Altura', speBarrasAltura.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Barras.Margem', speBarrasMargem.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'QRCode.Tipo', speQRCodeTipo.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'QRCode.LarguraModulo', speQRCodeLarguraModulo.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'QRCode.ErrorLevel', speQRCodeErrorLevel.Value);
  Ini.WriteBool(SECAO_POSPRINTER, 'Logo.IgnorarLogo', chkLogoIgnorarLogo.Checked);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Logo.KeyCode1', speLogoKeyCode1.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Logo.KeyCode2', speLogoKeyCode2.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Logo.FatorX', speLogoFatorX.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Logo.FatorY', speLogoFatorY.Value);
  Ini.WriteBool(SECAO_POSPRINTER, 'Gaveta.SinalInvertido', chkGavetaSinalInvertido.Checked);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Gaveta.TempoON', speGavetaTempoON.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'Gaveta.TempoOFF', speGavetaTempoOFF.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Largura', speModoPaginaLargura.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Altura', speModoPaginaAltura.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Esquerda', speModoPaginaEsquerda.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Topo', speModoPaginaTopo.Value);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.Direcao', cbxModoPaginaDirecao.ItemIndex);
  Ini.WriteInteger(SECAO_POSPRINTER, 'ModoPagina.EspacoEntreLinhas', speModoPaginaEspacoEntreLinhas.Value);
end;

procedure TfrmConfig.CarregarDANFE(Ini: TCustomIniFile);
begin
  cbxDANFE.ItemIndex := IndexText(Ini.ReadString(SECAO_DANFE, 'Componente', DANFE_CODIGOS[0]), DANFE_CODIGOS);
  if cbxDANFE.ItemIndex < 0 then
    cbxDANFE.ItemIndex := 0;
end;

procedure TfrmConfig.SalvarDANFE(Ini: TCustomIniFile);
begin
  Ini.WriteString(SECAO_DANFE, 'Componente', DANFE_CODIGOS[cbxDANFE.ItemIndex]);
end;

end.
