unit ufrmemissaonfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  Grids, Spin, IniFiles, DateTimePicker, ACBrNFe, ACBrNFe.Classes, uemissaonfe;

type

  { TfrmEmissaoNFe }

  TfrmEmissaoNFe = class(TForm)
    tbrAcoes: TToolBar;
    tbtNovo: TToolButton;
    tbtAbrir: TToolButton;
    tbtSalvar: TToolButton;
    tbtValidar: TToolButton;
    tbtEmitir: TToolButton;
    pnlRodape: TPanel;
    lblSituacao: TLabel;
    btnFechar: TButton;
    pgcNFe: TPageControl;
    tabIdentificacao: TTabSheet;
    sbxIdentificacao: TScrollBox;
    grpIde: TGroupBox;
    lblIdeModelo: TLabel;
    cbxIdeModelo: TComboBox;
    lblIdeSerie: TLabel;
    speIdeSerie: TSpinEdit;
    lblIdeNNF: TLabel;
    speIdeNNF: TSpinEdit;
    lblIdeCNF: TLabel;
    speIdeCNF: TSpinEdit;
    lblIdeNatOp: TLabel;
    edtIdeNatOp: TEdit;
    lblIdeDhEmi: TLabel;
    dtpIdeDhEmi: TDateTimePicker;
    lblIdeDhSaiEnt: TLabel;
    dtpIdeDhSaiEnt: TDateTimePicker;
    lblIdeTpNF: TLabel;
    cbxIdeTpNF: TComboBox;
    lblIdeFinNFe: TLabel;
    cbxIdeFinNFe: TComboBox;
    lblIdeIdDest: TLabel;
    cbxIdeIdDest: TComboBox;
    lblIdeIndFinal: TLabel;
    cbxIdeIndFinal: TComboBox;
    lblIdeIndPres: TLabel;
    cbxIdeIndPres: TComboBox;
    lblIdeTpImp: TLabel;
    cbxIdeTpImp: TComboBox;
    lblIdeTpEmis: TLabel;
    cbxIdeTpEmis: TComboBox;
    lblIdeTpAmb: TLabel;
    cbxIdeTpAmb: TComboBox;
    lblIdeCMunFG: TLabel;
    speIdeCMunFG: TSpinEdit;
    grpIdeContingencia: TGroupBox;
    lblIdeDhCont: TLabel;
    dtpIdeDhCont: TDateTimePicker;
    lblIdeXJust: TLabel;
    edtIdeXJust: TEdit;
    grpIdeIntermediador: TGroupBox;
    lblIdeIndIntermed: TLabel;
    cbxIdeIndIntermed: TComboBox;
    lblIntermedCNPJ: TLabel;
    edtIntermedCNPJ: TEdit;
    lblIntermedIdCadIntTran: TLabel;
    edtIntermedIdCadIntTran: TEdit;
    grpIdeReforma: TGroupBox;
    lblIdeTpNFCredito: TLabel;
    cbxIdeTpNFCredito: TComboBox;
    lblIdeTpNFDebito: TLabel;
    cbxIdeTpNFDebito: TComboBox;
    lblIdeCMunFGIBS: TLabel;
    speIdeCMunFGIBS: TSpinEdit;
    tabEmitente: TTabSheet;
    pnlEmitBotoes: TPanel;
    btnEmitRecarregar: TButton;
    sbxEmitente: TScrollBox;
    grpEmit: TGroupBox;
    lblEmitCNPJCPF: TLabel;
    edtEmitCNPJCPF: TEdit;
    lblEmitIE: TLabel;
    edtEmitIE: TEdit;
    lblEmitIEST: TLabel;
    edtEmitIEST: TEdit;
    lblEmitIM: TLabel;
    edtEmitIM: TEdit;
    lblEmitCNAE: TLabel;
    edtEmitCNAE: TEdit;
    lblEmitXNome: TLabel;
    edtEmitXNome: TEdit;
    lblEmitXFant: TLabel;
    edtEmitXFant: TEdit;
    lblEmitCRT: TLabel;
    cbxEmitCRT: TComboBox;
    grpEmitEndereco: TGroupBox;
    lblEmitXLgr: TLabel;
    edtEmitXLgr: TEdit;
    lblEmitNro: TLabel;
    edtEmitNro: TEdit;
    lblEmitXCpl: TLabel;
    edtEmitXCpl: TEdit;
    lblEmitXBairro: TLabel;
    edtEmitXBairro: TEdit;
    lblEmitCMun: TLabel;
    speEmitCMun: TSpinEdit;
    lblEmitXMun: TLabel;
    edtEmitXMun: TEdit;
    lblEmitUF: TLabel;
    cbxEmitUF: TComboBox;
    lblEmitCEP: TLabel;
    edtEmitCEP: TEdit;
    lblEmitFone: TLabel;
    edtEmitFone: TEdit;
    tabDestinatario: TTabSheet;
    sbxDestinatario: TScrollBox;
    grpDest: TGroupBox;
    lblDestCNPJCPF: TLabel;
    edtDestCNPJCPF: TEdit;
    lblDestIdEstrangeiro: TLabel;
    edtDestIdEstrangeiro: TEdit;
    lblDestXNome: TLabel;
    edtDestXNome: TEdit;
    lblDestIndIEDest: TLabel;
    cbxDestIndIEDest: TComboBox;
    lblDestIE: TLabel;
    edtDestIE: TEdit;
    lblDestISUF: TLabel;
    edtDestISUF: TEdit;
    lblDestIM: TLabel;
    edtDestIM: TEdit;
    lblDestEmail: TLabel;
    edtDestEmail: TEdit;
    grpDestEndereco: TGroupBox;
    lblDestXLgr: TLabel;
    edtDestXLgr: TEdit;
    lblDestNro: TLabel;
    edtDestNro: TEdit;
    lblDestXCpl: TLabel;
    edtDestXCpl: TEdit;
    lblDestXBairro: TLabel;
    edtDestXBairro: TEdit;
    lblDestCMun: TLabel;
    speDestCMun: TSpinEdit;
    lblDestXMun: TLabel;
    edtDestXMun: TEdit;
    lblDestUF: TLabel;
    cbxDestUF: TComboBox;
    lblDestCEP: TLabel;
    edtDestCEP: TEdit;
    lblDestCPais: TLabel;
    speDestCPais: TSpinEdit;
    lblDestXPais: TLabel;
    edtDestXPais: TEdit;
    lblDestFone: TLabel;
    edtDestFone: TEdit;
    tabItens: TTabSheet;
    pnlItensBotoes: TPanel;
    btnItemNovo: TButton;
    btnItemExcluir: TButton;
    btnItemCalcular: TButton;
    grdItens: TStringGrid;
    pgcItem: TPageControl;
    tabItemProduto: TTabSheet;
    sbxItemProduto: TScrollBox;
    grpProd: TGroupBox;
    lblProdCProd: TLabel;
    edtProdCProd: TEdit;
    lblProdCEAN: TLabel;
    edtProdCEAN: TEdit;
    lblProdXProd: TLabel;
    edtProdXProd: TEdit;
    lblProdNCM: TLabel;
    edtProdNCM: TEdit;
    lblProdCEST: TLabel;
    edtProdCEST: TEdit;
    lblProdCFOP: TLabel;
    edtProdCFOP: TEdit;
    lblProdUCom: TLabel;
    edtProdUCom: TEdit;
    lblProdQCom: TLabel;
    speProdQCom: TFloatSpinEdit;
    lblProdVUnCom: TLabel;
    speProdVUnCom: TFloatSpinEdit;
    lblProdVProd: TLabel;
    speProdVProd: TFloatSpinEdit;
    lblProdCBenef: TLabel;
    edtProdCBenef: TEdit;
    lblProdIndTot: TLabel;
    chkProdIndTot: TCheckBox;
    grpProdTributavel: TGroupBox;
    lblProdCEANTrib: TLabel;
    edtProdCEANTrib: TEdit;
    lblProdUTrib: TLabel;
    edtProdUTrib: TEdit;
    lblProdQTrib: TLabel;
    speProdQTrib: TFloatSpinEdit;
    lblProdVUnTrib: TLabel;
    speProdVUnTrib: TFloatSpinEdit;
    grpProdValores: TGroupBox;
    lblProdVFrete: TLabel;
    speProdVFrete: TFloatSpinEdit;
    lblProdVSeg: TLabel;
    speProdVSeg: TFloatSpinEdit;
    lblProdVDesc: TLabel;
    speProdVDesc: TFloatSpinEdit;
    lblProdVOutro: TLabel;
    speProdVOutro: TFloatSpinEdit;
    lblProdXPed: TLabel;
    edtProdXPed: TEdit;
    lblProdNItemPed: TLabel;
    edtProdNItemPed: TEdit;
    lblProdInfAdProd: TLabel;
    edtProdInfAdProd: TEdit;
    tabItemICMS: TTabSheet;
    sbxItemICMS: TScrollBox;
    grpICMS: TGroupBox;
    lblICMSOrig: TLabel;
    cbxICMSOrig: TComboBox;
    lblICMSCST: TLabel;
    cbxICMSCST: TComboBox;
    lblICMSCSOSN: TLabel;
    cbxICMSCSOSN: TComboBox;
    lblICMSModBC: TLabel;
    cbxICMSModBC: TComboBox;
    lblICMSPRedBC: TLabel;
    speICMSPRedBC: TFloatSpinEdit;
    lblICMSVBC: TLabel;
    speICMSVBC: TFloatSpinEdit;
    lblICMSPICMS: TLabel;
    speICMSPICMS: TFloatSpinEdit;
    lblICMSVICMS: TLabel;
    speICMSVICMS: TFloatSpinEdit;
    lblICMSPFCP: TLabel;
    speICMSPFCP: TFloatSpinEdit;
    lblICMSVFCP: TLabel;
    speICMSVFCP: TFloatSpinEdit;
    grpICMSST: TGroupBox;
    lblICMSModBCST: TLabel;
    cbxICMSModBCST: TComboBox;
    lblICMSPMVAST: TLabel;
    speICMSPMVAST: TFloatSpinEdit;
    lblICMSPRedBCST: TLabel;
    speICMSPRedBCST: TFloatSpinEdit;
    lblICMSVBCST: TLabel;
    speICMSVBCST: TFloatSpinEdit;
    lblICMSPICMSST: TLabel;
    speICMSPICMSST: TFloatSpinEdit;
    lblICMSVICMSST: TLabel;
    speICMSVICMSST: TFloatSpinEdit;
    grpICMSOutros: TGroupBox;
    lblICMSPCredSN: TLabel;
    speICMSPCredSN: TFloatSpinEdit;
    lblICMSVCredICMSSN: TLabel;
    speICMSVCredICMSSN: TFloatSpinEdit;
    lblICMSVICMSDeson: TLabel;
    speICMSVICMSDeson: TFloatSpinEdit;
    lblICMSMotDesICMS: TLabel;
    cbxICMSMotDesICMS: TComboBox;
    tabItemIPI: TTabSheet;
    sbxItemIPI: TScrollBox;
    grpIPI: TGroupBox;
    lblIPICEnq: TLabel;
    edtIPICEnq: TEdit;
    lblIPICST: TLabel;
    cbxIPICST: TComboBox;
    lblIPIVBC: TLabel;
    speIPIVBC: TFloatSpinEdit;
    lblIPIPIPI: TLabel;
    speIPIPIPI: TFloatSpinEdit;
    lblIPIVIPI: TLabel;
    speIPIVIPI: TFloatSpinEdit;
    tabItemPISCOFINS: TTabSheet;
    sbxItemPISCOFINS: TScrollBox;
    grpPIS: TGroupBox;
    lblPISCST: TLabel;
    cbxPISCST: TComboBox;
    lblPISVBC: TLabel;
    spePISVBC: TFloatSpinEdit;
    lblPISPPIS: TLabel;
    spePISPPIS: TFloatSpinEdit;
    lblPISVPIS: TLabel;
    spePISVPIS: TFloatSpinEdit;
    grpCOFINS: TGroupBox;
    lblCOFINSCST: TLabel;
    cbxCOFINSCST: TComboBox;
    lblCOFINSVBC: TLabel;
    speCOFINSVBC: TFloatSpinEdit;
    lblCOFINSPCOFINS: TLabel;
    speCOFINSPCOFINS: TFloatSpinEdit;
    lblCOFINSVCOFINS: TLabel;
    speCOFINSVCOFINS: TFloatSpinEdit;
    tabItemIBSCBS: TTabSheet;
    sbxItemIBSCBS: TScrollBox;
    grpIBSCBS: TGroupBox;
    lblIBSCBSCST: TLabel;
    cbxIBSCBSCST: TComboBox;
    lblIBSCBSCClassTrib: TLabel;
    edtIBSCBSCClassTrib: TEdit;
    lblIBSCBSVBC: TLabel;
    speIBSCBSVBC: TFloatSpinEdit;
    lblIBSUFPIBSUF: TLabel;
    speIBSUFPIBSUF: TFloatSpinEdit;
    lblIBSUFVIBSUF: TLabel;
    speIBSUFVIBSUF: TFloatSpinEdit;
    lblIBSMunPIBSMun: TLabel;
    speIBSMunPIBSMun: TFloatSpinEdit;
    lblIBSMunVIBSMun: TLabel;
    speIBSMunVIBSMun: TFloatSpinEdit;
    lblCBSPCBS: TLabel;
    speCBSPCBS: TFloatSpinEdit;
    lblCBSVCBS: TLabel;
    speCBSVCBS: TFloatSpinEdit;
    tabItemDevolucao: TTabSheet;
    sbxItemDevolucao: TScrollBox;
    grpDevolucao: TGroupBox;
    lblDevolPDevol: TLabel;
    speDevolPDevol: TFloatSpinEdit;
    lblDevolVIPIDevol: TLabel;
    speDevolVIPIDevol: TFloatSpinEdit;
    tabTransporte: TTabSheet;
    sbxTransporte: TScrollBox;
    grpTransp: TGroupBox;
    lblTranspModFrete: TLabel;
    cbxTranspModFrete: TComboBox;
    grpTransportadora: TGroupBox;
    lblTranspCNPJCPF: TLabel;
    edtTranspCNPJCPF: TEdit;
    lblTranspXNome: TLabel;
    edtTranspXNome: TEdit;
    lblTranspIE: TLabel;
    edtTranspIE: TEdit;
    lblTranspXEnder: TLabel;
    edtTranspXEnder: TEdit;
    lblTranspXMun: TLabel;
    edtTranspXMun: TEdit;
    lblTranspUF: TLabel;
    cbxTranspUF: TComboBox;
    grpVeiculo: TGroupBox;
    lblVeicPlaca: TLabel;
    edtVeicPlaca: TEdit;
    lblVeicUF: TLabel;
    cbxVeicUF: TComboBox;
    lblVeicRNTC: TLabel;
    edtVeicRNTC: TEdit;
    grpVolumes: TGroupBox;
    pnlVolBotoes: TPanel;
    btnVolAdicionar: TButton;
    btnVolRemover: TButton;
    grdVolumes: TStringGrid;
    tabPagamento: TTabSheet;
    sbxPagamento: TScrollBox;
    grpPagamentos: TGroupBox;
    pnlPagBotoes: TPanel;
    btnPagAdicionar: TButton;
    btnPagRemover: TButton;
    grdPagamentos: TStringGrid;
    grpFatura: TGroupBox;
    lblCobrNFat: TLabel;
    edtCobrNFat: TEdit;
    lblCobrVOrig: TLabel;
    speCobrVOrig: TFloatSpinEdit;
    lblCobrVDesc: TLabel;
    speCobrVDesc: TFloatSpinEdit;
    lblCobrVLiq: TLabel;
    speCobrVLiq: TFloatSpinEdit;
    grpDuplicatas: TGroupBox;
    pnlDupBotoes: TPanel;
    btnDupAdicionar: TButton;
    btnDupRemover: TButton;
    grdDuplicatas: TStringGrid;
    tabReferencias: TTabSheet;
    grpReferencias: TGroupBox;
    pnlRefBotoes: TPanel;
    btnRefAdicionar: TButton;
    btnRefRemover: TButton;
    grdReferencias: TStringGrid;
    tabInfAdicionais: TTabSheet;
    grpInfAdFisco: TGroupBox;
    mmoInfAdFisco: TMemo;
    grpInfCpl: TGroupBox;
    mmoInfCpl: TMemo;
    tabTotais: TTabSheet;
    sbxTotais: TScrollBox;
    grpTotaisICMS: TGroupBox;
    lblTotVProd: TLabel;
    speTotVProd: TFloatSpinEdit;
    lblTotVNF: TLabel;
    speTotVNF: TFloatSpinEdit;
    lblTotVBC: TLabel;
    speTotVBC: TFloatSpinEdit;
    lblTotVICMS: TLabel;
    speTotVICMS: TFloatSpinEdit;
    lblTotVICMSDeson: TLabel;
    speTotVICMSDeson: TFloatSpinEdit;
    lblTotVFCP: TLabel;
    speTotVFCP: TFloatSpinEdit;
    lblTotVBCST: TLabel;
    speTotVBCST: TFloatSpinEdit;
    lblTotVST: TLabel;
    speTotVST: TFloatSpinEdit;
    lblTotVFCPST: TLabel;
    speTotVFCPST: TFloatSpinEdit;
    lblTotVIPI: TLabel;
    speTotVIPI: TFloatSpinEdit;
    lblTotVIPIDevol: TLabel;
    speTotVIPIDevol: TFloatSpinEdit;
    lblTotVII: TLabel;
    speTotVII: TFloatSpinEdit;
    lblTotVPIS: TLabel;
    speTotVPIS: TFloatSpinEdit;
    lblTotVCOFINS: TLabel;
    speTotVCOFINS: TFloatSpinEdit;
    lblTotVFrete: TLabel;
    speTotVFrete: TFloatSpinEdit;
    lblTotVSeg: TLabel;
    speTotVSeg: TFloatSpinEdit;
    lblTotVDesc: TLabel;
    speTotVDesc: TFloatSpinEdit;
    lblTotVOutro: TLabel;
    speTotVOutro: TFloatSpinEdit;
    lblTotVTroco: TLabel;
    speTotVTroco: TFloatSpinEdit;
    grpTotaisIBSCBS: TGroupBox;
    lblTotVBCIBSCBS: TLabel;
    speTotVBCIBSCBS: TFloatSpinEdit;
    lblTotVIBS: TLabel;
    speTotVIBS: TFloatSpinEdit;
    lblTotVIBSUF: TLabel;
    speTotVIBSUF: TFloatSpinEdit;
    lblTotVIBSMun: TLabel;
    speTotVIBSMun: TFloatSpinEdit;
    lblTotVCBS: TLabel;
    speTotVCBS: TFloatSpinEdit;
    tabValidacao: TTabSheet;
    grpValidacao: TGroupBox;
    mmoValidacao: TMemo;
    dlgAbrirXML: TOpenDialog;
    dlgSalvarXML: TSaveDialog;
    ACBrNFe1: TACBrNFe;
    procedure FormCreate(Sender: TObject);
    procedure tbtNovoClick(Sender: TObject);
    procedure tbtAbrirClick(Sender: TObject);
    procedure tbtSalvarClick(Sender: TObject);
    procedure tbtValidarClick(Sender: TObject);
    procedure tbtEmitirClick(Sender: TObject);
    procedure pgcNFeChange(Sender: TObject);
    procedure cbxIdeModeloChange(Sender: TObject);
    procedure cbxIdeFinNFeChange(Sender: TObject);
    procedure cbxDestUFChange(Sender: TObject);
    procedure cbxEmitCRTChange(Sender: TObject);
    procedure cbxAjustarTelaChange(Sender: TObject);
    procedure btnEmitRecarregarClick(Sender: TObject);
    procedure btnItemNovoClick(Sender: TObject);
    procedure btnItemExcluirClick(Sender: TObject);
    procedure btnItemCalcularClick(Sender: TObject);
    procedure grdItensBeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure grdItensSelection(Sender: TObject; aCol, aRow: Integer);
    procedure btnVolAdicionarClick(Sender: TObject);
    procedure btnVolRemoverClick(Sender: TObject);
    procedure btnPagAdicionarClick(Sender: TObject);
    procedure btnPagRemoverClick(Sender: TObject);
    procedure btnDupAdicionarClick(Sender: TObject);
    procedure btnDupRemoverClick(Sender: TObject);
    procedure btnRefAdicionarClick(Sender: TObject);
    procedure btnRefRemoverClick(Sender: TObject);
  private
    FArquivoIni: string;
    FEmissao: TEmissaoNFe;
    FItemAtual: integer;
    FCarregando: Boolean;
    procedure CarregarIde(Nota: TNFe);
    procedure LerIde(Nota: TNFe);
    procedure CarregarEmit(Nota: TNFe);
    procedure LerEmit(Nota: TNFe);
    procedure CarregarDest(Nota: TNFe);
    procedure LerDest(Nota: TNFe);
    procedure CarregarTransp(Nota: TNFe);
    procedure LerTransp(Nota: TNFe);
    procedure CarregarCobr(Nota: TNFe);
    procedure LerCobr(Nota: TNFe);
    procedure CarregarTotais(Nota: TNFe);
    procedure CarregarItem(Det: TDetCollectionItem);
    procedure LerItem(Det: TDetCollectionItem);
    procedure CarregarVolumes(Nota: TNFe);
    procedure LerVolumes(Nota: TNFe);
    procedure CarregarPagamentos(Nota: TNFe);
    procedure LerPagamentos(Nota: TNFe);
    procedure CarregarDuplicatas(Nota: TNFe);
    procedure LerDuplicatas(Nota: TNFe);
    procedure CarregarReferencias(Nota: TNFe);
    procedure LerReferencias(Nota: TNFe);
    procedure CarregarGradeItens;
    procedure AtualizarLinhaItem(Index: integer);
    procedure GravarItemAtual;
    procedure AjustarTela;
    procedure NovaNotaDaConfiguracao;
  public
    procedure Iniciar(Ini: TCustomIniFile);
    procedure CarregarTela;
    procedure LerTela;
    procedure SelecionarItem(Index: integer);
    procedure ExcluirItem(Index: integer);
    procedure AbrirArquivo(const Arquivo: string);
    procedure SalvarArquivo(const Arquivo: string);
    function ValidarNota: Boolean;
    property Emissao: TEmissaoNFe read FEmissao;
    property ItemAtual: integer read FItemAtual;
    class procedure Exibir(const ArquivoIni: string);
  end;

function CodigoDoTexto(const Texto: string): string;
function CodigoSelecionado(Combo: TComboBox): string;
function IndiceDoCodigo(Itens: TStrings; const Codigo: string): integer;
procedure SelecionarCodigo(Combo: TComboBox; const Codigo: string);
function ValorDoTexto(const Texto: string): Double;

var
  frmEmissaoNFe: TfrmEmissaoNFe;

implementation

uses
  Math, DateUtils, ACBrUtil.Strings, ACBrUtil.Base, ACBrValidador, ACBrDFeUtil, pcnConversao,
  pcnConversaoNFe, ACBrDFe.Conversao;

{$R *.lfm}

const
  FORMATO_DATA = 'dd/mm/yyyy';
  // colunas das grades (mesma ordem do .lfm)
  COL_ITEM_NITEM = 0;
  COL_PAG_INDPAG = 0;
  COL_PAG_TPAG = 1;
  COL_PAG_XPAG = 2;
  COL_PAG_VPAG = 3;
  COL_PAG_TPINTEGRA = 4;
  COL_PAG_CNPJ = 5;
  COL_PAG_TBAND = 6;
  COL_PAG_CAUT = 7;
  COL_REF_TIPO = 0;
  COL_REF_CHAVE = 1;
  COL_REF_CUF = 2;
  COL_REF_AAMM = 3;
  COL_REF_CNPJCPF = 4;
  COL_REF_IE = 5;
  COL_REF_MODELO = 6;
  COL_REF_SERIE = 7;
  COL_REF_NNF = 8;
  COL_REF_NECF = 9;
  COL_REF_NCOO = 10;
  // índices da lista de tipos da coluna de referências
  REF_NFE = 0;
  REF_CTE = 1;
  REF_NF = 2;
  REF_NFP = 3;
  REF_ECF = 4;

  MSG_NOVA_NOTA = 'Descartar a nota atual e iniciar uma nova?';
  MSG_EXCLUIR_ITEM = 'Excluir o item %d?';
  MSG_XML_SALVO = 'XML salvo em %s';
  MSG_SEM_PENDENCIAS = 'Nenhuma pendência encontrada.';
  MSG_COM_PENDENCIAS = 'Há pendências na nota. Veja a aba Validação.';
  MSG_CONFIRMAR_EMISSAO = 'Emitir a %s nº %d, série %d, em %s?';
  MSG_AUTORIZADA = 'Nota autorizada.'#10'Chave: %s'#10'Protocolo: %s';
  MSG_NAO_AUTORIZADA = 'Nota não autorizada.'#10'%d - %s';
  MSG_SITUACAO_AUTORIZADA = 'Nota autorizada (protocolo %s). Alterações exigem nova emissão.';
  MSG_SITUACAO_RASCUNHO = 'Rascunho: a nota ainda não foi autorizada.';

function CodigoDoTexto(const Texto: string): string;
var
  P: integer;
begin
  // itens no formato "código - descrição"; itens sem código (ex.: "Não informado") valem vazio
  P := Pos(' - ', Texto);
  if P > 0 then
    Result := Copy(Texto, 1, P - 1)
  else
    Result := '';
end;

function CodigoSelecionado(Combo: TComboBox): string;
begin
  if Combo.ItemIndex < 0 then
    Result := ''
  else
    Result := CodigoDoTexto(Combo.Items[Combo.ItemIndex]);
end;

function IndiceDoCodigo(Itens: TStrings; const Codigo: string): integer;
var
  I: integer;
begin
  for I := 0 to Itens.Count - 1 do
    if CodigoDoTexto(Itens[I]) = Codigo then
      Exit(I);
  Result := -1;
end;

procedure SelecionarCodigo(Combo: TComboBox; const Codigo: string);
begin
  Combo.ItemIndex := IndiceDoCodigo(Combo.Items, Codigo);
end;

function TextoDoCodigo(Itens: TStrings; const Codigo: string): string;
var
  I: integer;
begin
  I := IndiceDoCodigo(Itens, Codigo);
  if I >= 0 then
    Result := Itens[I]
  else
    Result := Codigo;
end;

function ValorDoTexto(const Texto: string): Double;
var
  S: string;
  Formato: TFormatSettings;
begin
  // aceita vírgula ou ponto decimal; com vírgula, pontos são separadores de milhar
  S := Trim(Texto);
  if Pos(',', S) > 0 then
    S := StringReplace(StringReplace(S, '.', '', [rfReplaceAll]), ',', '.', []);
  Formato := DefaultFormatSettings;
  Formato.DecimalSeparator := '.';
  Result := StrToFloatDef(S, 0, Formato);
end;

function TextoDoValor(Valor: Double; Casas: integer = 2): string;
begin
  Result := FormatFloat('0.' + StringOfChar('0', Casas), Valor);
end;

function DataDoTexto(const Texto: string): TDateTime;
begin
  try
    Result := ScanDateTime(FORMATO_DATA, Trim(Texto));
  except
    Result := 0;
  end;
end;

function TextoDaData(Data: TDateTime): string;
begin
  if Data = 0 then
    Result := ''
  else
    Result := FormatDateTime(FORMATO_DATA, Data);
end;

function TextoCEP(CEP: integer): string;
begin
  // FormatarCEP(0) devolveria '00000-000'
  if CEP > 0 then
    Result := FormatarCEP(CEP)
  else
    Result := '';
end;

procedure CarregarDataOpcional(Picker: TDateTimePicker; Valor: TDateTime);
begin
  Picker.Checked := Valor > 0;
  if Valor > 0 then
    Picker.DateTime := Valor
  else
    Picker.DateTime := Now;
end;

function LerDataOpcional(Picker: TDateTimePicker): TDateTime;
begin
  if Picker.Checked then
    Result := Picker.DateTime
  else
    Result := 0;
end;

function LinhaVazia(Grade: TStringGrid; Linha: integer): Boolean;
var
  C: integer;
begin
  for C := 0 to Grade.ColCount - 1 do
    if Trim(Grade.Cells[C, Linha]) <> '' then
      Exit(False);
  Result := True;
end;

procedure RemoverLinhaAtual(Grade: TStringGrid);
begin
  if Grade.Row >= Grade.FixedRows then
    Grade.DeleteRow(Grade.Row);
end;

{ TfrmEmissaoNFe }

class procedure TfrmEmissaoNFe.Exibir(const ArquivoIni: string);
var
  Ini: TIniFile;
begin
  frmEmissaoNFe := TfrmEmissaoNFe.Create(Application);
  try
    frmEmissaoNFe.FArquivoIni := ArquivoIni;
    Ini := TIniFile.Create(ArquivoIni);
    try
      frmEmissaoNFe.Iniciar(Ini);
    finally
      Ini.Free;
    end;
    frmEmissaoNFe.ShowModal;
  finally
    FreeAndNil(frmEmissaoNFe);
  end;
end;

procedure TfrmEmissaoNFe.FormCreate(Sender: TObject);
begin
  FEmissao := TEmissaoNFe.Create(Self);
  FEmissao.ACBrNFe := ACBrNFe1;
  FItemAtual := -1;
  pgcNFe.ActivePage := tabIdentificacao;
  pgcItem.ActivePage := tabItemProduto;
end;

procedure TfrmEmissaoNFe.Iniciar(Ini: TCustomIniFile);
begin
  // mesmas configurações do ACBrNFe do frmMain (certificado, ambiente, UF, paths)
  ACBrNFe1.Configuracoes.LerIni(Ini);
  FEmissao.NovaNota(Ini);
  FItemAtual := -1;
  CarregarTela;
end;

procedure TfrmEmissaoNFe.NovaNotaDaConfiguracao;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(FArquivoIni);
  try
    FEmissao.NovaNota(Ini);
  finally
    Ini.Free;
  end;
  FItemAtual := -1;
  CarregarTela;
end;

procedure TfrmEmissaoNFe.CarregarTela;
var
  Nota: TNFe;
  Anterior: Boolean;
  Indice: integer;
begin
  Nota := FEmissao.NFe;
  Anterior := FCarregando;
  FCarregando := True;
  try
    CarregarIde(Nota);
    CarregarEmit(Nota);
    CarregarDest(Nota);
    CarregarTransp(Nota);
    CarregarVolumes(Nota);
    CarregarPagamentos(Nota);
    CarregarCobr(Nota);
    CarregarDuplicatas(Nota);
    CarregarReferencias(Nota);
    mmoInfAdFisco.Text := Nota.InfAdic.infAdFisco;
    mmoInfCpl.Text := Nota.InfAdic.infCpl;
    CarregarTotais(Nota);
    CarregarGradeItens;
  finally
    FCarregando := Anterior;
  end;
  // o editor ainda mostra o item anterior: não deve ser gravado por cima da nota recarregada
  Indice := FItemAtual;
  FItemAtual := -1;
  SelecionarItem(Min(Max(Indice, 0), Nota.Det.Count - 1));
  AjustarTela;
end;

procedure TfrmEmissaoNFe.LerTela;
var
  Nota: TNFe;
begin
  if FCarregando then
    Exit;
  Nota := FEmissao.NFe;
  GravarItemAtual;
  LerIde(Nota);
  LerEmit(Nota);
  LerDest(Nota);
  LerTransp(Nota);
  LerVolumes(Nota);
  LerPagamentos(Nota);
  LerCobr(Nota);
  LerDuplicatas(Nota);
  LerReferencias(Nota);
  Nota.InfAdic.infAdFisco := Trim(mmoInfAdFisco.Text);
  Nota.InfAdic.infCpl := Trim(mmoInfCpl.Text);
  if Nota.Emit.EnderEmit.UF <> '' then
    Nota.Ide.cUF := UFparaCodigoUF(Nota.Emit.EnderEmit.UF);
end;

procedure TfrmEmissaoNFe.AjustarTela;
var
  Nota: TNFe;
  NFCe, Simples, TemItens: Boolean;
begin
  Nota := FEmissao.NFe;
  NFCe := Nota.Ide.modelo = MODELO_NFCE;
  Simples := EhSimplesNacional(Nota);
  TemItens := Nota.Det.Count > 0;

  // NFC-e não referencia documentos (708), não tem cobrança (760) nem IPI (742)
  tabReferencias.TabVisible := not NFCe;
  grpFatura.Enabled := not NFCe;
  grpDuplicatas.Enabled := not NFCe;
  tabItemIPI.TabVisible := not NFCe;
  tabItemDevolucao.TabVisible := Nota.Ide.finNFe = fnDevolucao;

  grpIdeContingencia.Enabled := Nota.Ide.tpEmis <> teNormal;
  cbxIdeTpNFCredito.Enabled := Nota.Ide.finNFe = fnCredito;
  cbxIdeTpNFDebito.Enabled := Nota.Ide.finNFe = fnDebito;
  edtIntermedCNPJ.Enabled := Nota.Ide.indIntermed = iiOperacaoComIntermediador;
  edtIntermedIdCadIntTran.Enabled := edtIntermedCNPJ.Enabled;
  // na NFC-e o destinatário é só identificado (729, 730); isento não informa IE
  edtDestIE.Enabled := (not NFCe) and (Nota.Dest.indIEDest <> inIsento);
  edtDestISUF.Enabled := not NFCe;
  cbxDestIndIEDest.Enabled := not NFCe;
  edtEmitIEST.Enabled := not NFCe;

  lblICMSCST.Visible := not Simples;
  cbxICMSCST.Visible := not Simples;
  lblICMSCSOSN.Visible := Simples;
  cbxICMSCSOSN.Visible := Simples;
  lblICMSPCredSN.Visible := Simples;
  speICMSPCredSN.Visible := Simples;
  lblICMSVCredICMSSN.Visible := Simples;
  speICMSVCredICMSSN.Visible := Simples;

  pgcItem.Enabled := TemItens;
  btnItemExcluir.Enabled := TemItens;
  btnItemCalcular.Enabled := TemItens;

  if Nota.procNFe.nProt <> '' then
    lblSituacao.Caption := Format(MSG_SITUACAO_AUTORIZADA, [Nota.procNFe.nProt])
  else
    lblSituacao.Caption := MSG_SITUACAO_RASCUNHO;
end;

procedure TfrmEmissaoNFe.CarregarIde(Nota: TNFe);
begin
  SelecionarCodigo(cbxIdeModelo, IntToStr(Nota.Ide.modelo));
  speIdeSerie.Value := Nota.Ide.serie;
  speIdeNNF.Value := Nota.Ide.nNF;
  speIdeCNF.Value := Nota.Ide.cNF;
  edtIdeNatOp.Text := Nota.Ide.natOp;
  dtpIdeDhEmi.DateTime := Nota.Ide.dEmi;
  CarregarDataOpcional(dtpIdeDhSaiEnt, Nota.Ide.dSaiEnt);
  SelecionarCodigo(cbxIdeTpNF, tpNFToStr(Nota.Ide.tpNF));
  SelecionarCodigo(cbxIdeFinNFe, FinNFeToStr(Nota.Ide.finNFe));
  SelecionarCodigo(cbxIdeIdDest, DestinoOperacaoToStr(Nota.Ide.idDest));
  SelecionarCodigo(cbxIdeIndFinal, ConsumidorFinalToStr(Nota.Ide.indFinal));
  SelecionarCodigo(cbxIdeIndPres, PresencaCompradorToStr(Nota.Ide.indPres));
  SelecionarCodigo(cbxIdeTpImp, TpImpToStr(Nota.Ide.tpImp));
  SelecionarCodigo(cbxIdeTpEmis, TpEmisToStr(Nota.Ide.tpEmis));
  SelecionarCodigo(cbxIdeTpAmb, TpAmbToStr(Nota.Ide.tpAmb));
  speIdeCMunFG.Value := Nota.Ide.cMunFG;
  CarregarDataOpcional(dtpIdeDhCont, Nota.Ide.dhCont);
  edtIdeXJust.Text := Nota.Ide.xJust;
  SelecionarCodigo(cbxIdeIndIntermed, IndIntermedToStr(Nota.Ide.indIntermed));
  edtIntermedCNPJ.Text := FormatarCNPJouCPF(Nota.infIntermed.CNPJ);
  edtIntermedIdCadIntTran.Text := Nota.infIntermed.idCadIntTran;
  SelecionarCodigo(cbxIdeTpNFCredito, tpNFCreditoToStr(Nota.Ide.tpNFCredito));
  SelecionarCodigo(cbxIdeTpNFDebito, tpNFDebitoToStr(Nota.Ide.tpNFDebito));
  speIdeCMunFGIBS.Value := Nota.Ide.cMunFGIBS;
  edtIntermedCNPJ.Text := FormatarCNPJouCPF(Nota.infIntermed.CNPJ);
end;

procedure TfrmEmissaoNFe.LerIde(Nota: TNFe);
var
  Ok: Boolean;
begin
  Nota.Ide.modelo := StrToIntDef(CodigoSelecionado(cbxIdeModelo), MODELO_NFE);
  Nota.Ide.serie := speIdeSerie.Value;
  Nota.Ide.nNF := speIdeNNF.Value;
  Nota.Ide.cNF := speIdeCNF.Value;
  Nota.Ide.natOp := Trim(edtIdeNatOp.Text);
  Nota.Ide.dEmi := dtpIdeDhEmi.DateTime;
  Nota.Ide.dSaiEnt := LerDataOpcional(dtpIdeDhSaiEnt);
  if cbxIdeTpNF.ItemIndex >= 0 then
    Nota.Ide.tpNF := StrToTpNF(Ok, CodigoSelecionado(cbxIdeTpNF));
  if cbxIdeFinNFe.ItemIndex >= 0 then
    Nota.Ide.finNFe := StrToFinNFe(Ok, CodigoSelecionado(cbxIdeFinNFe));
  if cbxIdeIdDest.ItemIndex >= 0 then
    Nota.Ide.idDest := StrToDestinoOperacao(Ok, CodigoSelecionado(cbxIdeIdDest));
  if cbxIdeIndFinal.ItemIndex >= 0 then
    Nota.Ide.indFinal := StrToConsumidorFinal(Ok, CodigoSelecionado(cbxIdeIndFinal));
  if cbxIdeIndPres.ItemIndex >= 0 then
    Nota.Ide.indPres := StrToPresencaComprador(Ok, CodigoSelecionado(cbxIdeIndPres));
  if cbxIdeTpImp.ItemIndex >= 0 then
    Nota.Ide.tpImp := StrToTpImp(Ok, CodigoSelecionado(cbxIdeTpImp));
  if cbxIdeTpEmis.ItemIndex >= 0 then
    Nota.Ide.tpEmis := StrToTpEmis(Ok, CodigoSelecionado(cbxIdeTpEmis));
  if cbxIdeTpAmb.ItemIndex >= 0 then
    Nota.Ide.tpAmb := StrToTpAmb(Ok, CodigoSelecionado(cbxIdeTpAmb));
  Nota.Ide.cMunFG := speIdeCMunFG.Value;
  Nota.Ide.dhCont := LerDataOpcional(dtpIdeDhCont);
  Nota.Ide.xJust := Trim(edtIdeXJust.Text);
  if cbxIdeIndIntermed.ItemIndex >= 0 then
    Nota.Ide.indIntermed := StrToIndIntermed(Ok, CodigoSelecionado(cbxIdeIndIntermed));
  Nota.infIntermed.CNPJ := UpperCase(OnlyAlphaNum(edtIntermedCNPJ.Text));
  Nota.infIntermed.idCadIntTran := Trim(edtIntermedIdCadIntTran.Text);
  if cbxIdeTpNFCredito.ItemIndex >= 0 then
    Nota.Ide.tpNFCredito := StrTotpNFCredito(CodigoSelecionado(cbxIdeTpNFCredito));
  if cbxIdeTpNFDebito.ItemIndex >= 0 then
    Nota.Ide.tpNFDebito := StrTotpNFDebito(CodigoSelecionado(cbxIdeTpNFDebito));
  Nota.Ide.cMunFGIBS := speIdeCMunFGIBS.Value;
end;

procedure TfrmEmissaoNFe.CarregarEmit(Nota: TNFe);
begin
  edtEmitCNPJCPF.Text := FormatarCNPJouCPF(Nota.Emit.CNPJCPF);
  edtEmitIE.Text := Nota.Emit.IE;
  edtEmitIEST.Text := Nota.Emit.IEST;
  edtEmitIM.Text := Nota.Emit.IM;
  edtEmitCNAE.Text := Nota.Emit.CNAE;
  edtEmitXNome.Text := Nota.Emit.xNome;
  edtEmitXFant.Text := Nota.Emit.xFant;
  SelecionarCodigo(cbxEmitCRT, CRTToStr(Nota.Emit.CRT));
  edtEmitXLgr.Text := Nota.Emit.EnderEmit.xLgr;
  edtEmitNro.Text := Nota.Emit.EnderEmit.nro;
  edtEmitXCpl.Text := Nota.Emit.EnderEmit.xCpl;
  edtEmitXBairro.Text := Nota.Emit.EnderEmit.xBairro;
  speEmitCMun.Value := Nota.Emit.EnderEmit.cMun;
  edtEmitXMun.Text := Nota.Emit.EnderEmit.xMun;
  cbxEmitUF.ItemIndex := cbxEmitUF.Items.IndexOf(Nota.Emit.EnderEmit.UF);
  edtEmitCEP.Text := TextoCEP(Nota.Emit.EnderEmit.CEP);
  edtEmitFone.Text := Nota.Emit.EnderEmit.fone;
end;

procedure TfrmEmissaoNFe.LerEmit(Nota: TNFe);
var
  Ok: Boolean;
begin
  Nota.Emit.CNPJCPF := UpperCase(OnlyAlphaNum(edtEmitCNPJCPF.Text));
  Nota.Emit.IE := Trim(edtEmitIE.Text);
  Nota.Emit.IEST := Trim(edtEmitIEST.Text);
  Nota.Emit.IM := Trim(edtEmitIM.Text);
  Nota.Emit.CNAE := Trim(edtEmitCNAE.Text);
  Nota.Emit.xNome := Trim(edtEmitXNome.Text);
  Nota.Emit.xFant := Trim(edtEmitXFant.Text);
  if cbxEmitCRT.ItemIndex >= 0 then
    Nota.Emit.CRT := StrToCRT(Ok, CodigoSelecionado(cbxEmitCRT));
  Nota.Emit.EnderEmit.xLgr := Trim(edtEmitXLgr.Text);
  Nota.Emit.EnderEmit.nro := Trim(edtEmitNro.Text);
  Nota.Emit.EnderEmit.xCpl := Trim(edtEmitXCpl.Text);
  Nota.Emit.EnderEmit.xBairro := Trim(edtEmitXBairro.Text);
  Nota.Emit.EnderEmit.cMun := speEmitCMun.Value;
  Nota.Emit.EnderEmit.xMun := Trim(edtEmitXMun.Text);
  Nota.Emit.EnderEmit.UF := cbxEmitUF.Text;
  Nota.Emit.EnderEmit.CEP := StrToIntDef(OnlyNumber(edtEmitCEP.Text), 0);
  Nota.Emit.EnderEmit.fone := OnlyNumber(edtEmitFone.Text);
end;

procedure TfrmEmissaoNFe.CarregarDest(Nota: TNFe);
begin
  edtDestCNPJCPF.Text := FormatarCNPJouCPF(Nota.Dest.CNPJCPF);
  edtDestIdEstrangeiro.Text := Nota.Dest.idEstrangeiro;
  edtDestXNome.Text := Nota.Dest.xNome;
  SelecionarCodigo(cbxDestIndIEDest, indIEDestToStr(Nota.Dest.indIEDest));
  edtDestIE.Text := Nota.Dest.IE;
  edtDestISUF.Text := Nota.Dest.ISUF;
  edtDestIM.Text := Nota.Dest.IM;
  edtDestEmail.Text := Nota.Dest.Email;
  edtDestXLgr.Text := Nota.Dest.EnderDest.xLgr;
  edtDestNro.Text := Nota.Dest.EnderDest.nro;
  edtDestXCpl.Text := Nota.Dest.EnderDest.xCpl;
  edtDestXBairro.Text := Nota.Dest.EnderDest.xBairro;
  speDestCMun.Value := Nota.Dest.EnderDest.cMun;
  edtDestXMun.Text := Nota.Dest.EnderDest.xMun;
  cbxDestUF.ItemIndex := cbxDestUF.Items.IndexOf(Nota.Dest.EnderDest.UF);
  edtDestCEP.Text := TextoCEP(Nota.Dest.EnderDest.CEP);
  speDestCPais.Value := Nota.Dest.EnderDest.cPais;
  edtDestXPais.Text := Nota.Dest.EnderDest.xPais;
  edtDestFone.Text := Nota.Dest.EnderDest.fone;
end;

procedure TfrmEmissaoNFe.LerDest(Nota: TNFe);
var
  Ok: Boolean;
begin
  Nota.Dest.CNPJCPF := UpperCase(OnlyAlphaNum(edtDestCNPJCPF.Text));
  Nota.Dest.idEstrangeiro := Trim(edtDestIdEstrangeiro.Text);
  Nota.Dest.xNome := Trim(edtDestXNome.Text);
  if cbxDestIndIEDest.ItemIndex >= 0 then
    Nota.Dest.indIEDest := StrToindIEDest(Ok, CodigoSelecionado(cbxDestIndIEDest));
  Nota.Dest.IE := Trim(edtDestIE.Text);
  Nota.Dest.ISUF := Trim(edtDestISUF.Text);
  Nota.Dest.IM := Trim(edtDestIM.Text);
  Nota.Dest.Email := Trim(edtDestEmail.Text);
  Nota.Dest.EnderDest.xLgr := Trim(edtDestXLgr.Text);
  Nota.Dest.EnderDest.nro := Trim(edtDestNro.Text);
  Nota.Dest.EnderDest.xCpl := Trim(edtDestXCpl.Text);
  Nota.Dest.EnderDest.xBairro := Trim(edtDestXBairro.Text);
  Nota.Dest.EnderDest.cMun := speDestCMun.Value;
  Nota.Dest.EnderDest.xMun := Trim(edtDestXMun.Text);
  Nota.Dest.EnderDest.UF := cbxDestUF.Text;
  Nota.Dest.EnderDest.CEP := StrToIntDef(OnlyNumber(edtDestCEP.Text), 0);
  Nota.Dest.EnderDest.cPais := speDestCPais.Value;
  Nota.Dest.EnderDest.xPais := Trim(edtDestXPais.Text);
  Nota.Dest.EnderDest.fone := OnlyNumber(edtDestFone.Text);
end;

procedure TfrmEmissaoNFe.CarregarTransp(Nota: TNFe);
begin
  SelecionarCodigo(cbxTranspModFrete, modFreteToStr(Nota.Transp.modFrete));
  edtTranspCNPJCPF.Text := FormatarCNPJouCPF(Nota.Transp.Transporta.CNPJCPF);
  edtTranspXNome.Text := Nota.Transp.Transporta.xNome;
  edtTranspIE.Text := Nota.Transp.Transporta.IE;
  edtTranspXEnder.Text := Nota.Transp.Transporta.xEnder;
  edtTranspXMun.Text := Nota.Transp.Transporta.xMun;
  cbxTranspUF.ItemIndex := cbxTranspUF.Items.IndexOf(Nota.Transp.Transporta.UF);
  edtVeicPlaca.Text := Nota.Transp.veicTransp.placa;
  cbxVeicUF.ItemIndex := cbxVeicUF.Items.IndexOf(Nota.Transp.veicTransp.UF);
  edtVeicRNTC.Text := Nota.Transp.veicTransp.RNTC;
end;

procedure TfrmEmissaoNFe.LerTransp(Nota: TNFe);
var
  Ok: Boolean;
begin
  if cbxTranspModFrete.ItemIndex >= 0 then
    Nota.Transp.modFrete := StrTomodFrete(Ok, CodigoSelecionado(cbxTranspModFrete));
  Nota.Transp.Transporta.CNPJCPF := UpperCase(OnlyAlphaNum(edtTranspCNPJCPF.Text));
  Nota.Transp.Transporta.xNome := Trim(edtTranspXNome.Text);
  Nota.Transp.Transporta.IE := Trim(edtTranspIE.Text);
  Nota.Transp.Transporta.xEnder := Trim(edtTranspXEnder.Text);
  Nota.Transp.Transporta.xMun := Trim(edtTranspXMun.Text);
  Nota.Transp.Transporta.UF := cbxTranspUF.Text;
  Nota.Transp.veicTransp.placa := Trim(edtVeicPlaca.Text);
  Nota.Transp.veicTransp.UF := cbxVeicUF.Text;
  Nota.Transp.veicTransp.RNTC := Trim(edtVeicRNTC.Text);
end;

procedure TfrmEmissaoNFe.CarregarCobr(Nota: TNFe);
begin
  edtCobrNFat.Text := Nota.Cobr.Fat.nFat;
  speCobrVOrig.Value := Nota.Cobr.Fat.vOrig;
  speCobrVDesc.Value := Nota.Cobr.Fat.vDesc;
  speCobrVLiq.Value := Nota.Cobr.Fat.vLiq;
end;

procedure TfrmEmissaoNFe.LerCobr(Nota: TNFe);
begin
  Nota.Cobr.Fat.nFat := Trim(edtCobrNFat.Text);
  Nota.Cobr.Fat.vOrig := speCobrVOrig.Value;
  Nota.Cobr.Fat.vDesc := speCobrVDesc.Value;
  Nota.Cobr.Fat.vLiq := speCobrVLiq.Value;
end;

procedure TfrmEmissaoNFe.CarregarTotais(Nota: TNFe);
begin
  speTotVProd.Value := Nota.Total.ICMSTot.vProd;
  speTotVNF.Value := Nota.Total.ICMSTot.vNF;
  speTotVBC.Value := Nota.Total.ICMSTot.vBC;
  speTotVICMS.Value := Nota.Total.ICMSTot.vICMS;
  speTotVICMSDeson.Value := Nota.Total.ICMSTot.vICMSDeson;
  speTotVFCP.Value := Nota.Total.ICMSTot.vFCP;
  speTotVBCST.Value := Nota.Total.ICMSTot.vBCST;
  speTotVST.Value := Nota.Total.ICMSTot.vST;
  speTotVFCPST.Value := Nota.Total.ICMSTot.vFCPST;
  speTotVIPI.Value := Nota.Total.ICMSTot.vIPI;
  speTotVIPIDevol.Value := Nota.Total.ICMSTot.vIPIDevol;
  speTotVII.Value := Nota.Total.ICMSTot.vII;
  speTotVPIS.Value := Nota.Total.ICMSTot.vPIS;
  speTotVCOFINS.Value := Nota.Total.ICMSTot.vCOFINS;
  speTotVFrete.Value := Nota.Total.ICMSTot.vFrete;
  speTotVSeg.Value := Nota.Total.ICMSTot.vSeg;
  speTotVDesc.Value := Nota.Total.ICMSTot.vDesc;
  speTotVOutro.Value := Nota.Total.ICMSTot.vOutro;
  speTotVTroco.Value := Nota.pag.vTroco;
  speTotVBCIBSCBS.Value := Nota.Total.IBSCBSTot.vBCIBSCBS;
  speTotVIBS.Value := Nota.Total.IBSCBSTot.gIBS.vIBS;
  speTotVIBSUF.Value := Nota.Total.IBSCBSTot.gIBS.gIBSUFTot.vIBSUF;
  speTotVIBSMun.Value := Nota.Total.IBSCBSTot.gIBS.gIBSMunTot.vIBSMun;
  speTotVCBS.Value := Nota.Total.IBSCBSTot.gCBS.vCBS;
end;

procedure TfrmEmissaoNFe.CarregarItem(Det: TDetCollectionItem);
var
  Anterior: Boolean;
begin
  Anterior := FCarregando;
  FCarregando := True;
  try
    edtProdCProd.Text := Det.Prod.cProd;
    edtProdCEAN.Text := Det.Prod.cEAN;
    edtProdXProd.Text := Det.Prod.xProd;
    edtProdNCM.Text := Det.Prod.NCM;
    edtProdCEST.Text := Det.Prod.CEST;
    edtProdCFOP.Text := Det.Prod.CFOP;
    edtProdUCom.Text := Det.Prod.uCom;
    speProdQCom.Value := Det.Prod.qCom;
    speProdVUnCom.Value := Det.Prod.vUnCom;
    speProdVProd.Value := Det.Prod.vProd;
    edtProdCBenef.Text := Det.Prod.cBenef;
    chkProdIndTot.Checked := Det.Prod.IndTot = itSomaTotalNFe;
    edtProdCEANTrib.Text := Det.Prod.cEANTrib;
    edtProdUTrib.Text := Det.Prod.uTrib;
    speProdQTrib.Value := Det.Prod.qTrib;
    speProdVUnTrib.Value := Det.Prod.vUnTrib;
    speProdVFrete.Value := Det.Prod.vFrete;
    speProdVSeg.Value := Det.Prod.vSeg;
    speProdVDesc.Value := Det.Prod.vDesc;
    speProdVOutro.Value := Det.Prod.vOutro;
    edtProdXPed.Text := Det.Prod.xPed;
    edtProdNItemPed.Text := Det.Prod.nItemPed;
    edtProdInfAdProd.Text := Det.infAdProd;
    SelecionarCodigo(cbxICMSOrig, OrigToStr(Det.Imposto.ICMS.orig));
    SelecionarCodigo(cbxICMSModBC, modBCToStr(Det.Imposto.ICMS.modBC));
    speICMSPRedBC.Value := Det.Imposto.ICMS.pRedBC;
    speICMSVBC.Value := Det.Imposto.ICMS.vBC;
    speICMSPICMS.Value := Det.Imposto.ICMS.pICMS;
    speICMSVICMS.Value := Det.Imposto.ICMS.vICMS;
    speICMSPFCP.Value := Det.Imposto.ICMS.pFCP;
    speICMSVFCP.Value := Det.Imposto.ICMS.vFCP;
    SelecionarCodigo(cbxICMSModBCST, modBCSTToStr(Det.Imposto.ICMS.modBCST));
    speICMSPMVAST.Value := Det.Imposto.ICMS.pMVAST;
    speICMSPRedBCST.Value := Det.Imposto.ICMS.pRedBCST;
    speICMSVBCST.Value := Det.Imposto.ICMS.vBCST;
    speICMSPICMSST.Value := Det.Imposto.ICMS.pICMSST;
    speICMSVICMSST.Value := Det.Imposto.ICMS.vICMSST;
    speICMSPCredSN.Value := Det.Imposto.ICMS.pCredSN;
    speICMSVCredICMSSN.Value := Det.Imposto.ICMS.vCredICMSSN;
    speICMSVICMSDeson.Value := Det.Imposto.ICMS.vICMSDeson;
    edtIPICEnq.Text := Det.Imposto.IPI.cEnq;
    SelecionarCodigo(cbxIPICST, CSTIPIToStr(Det.Imposto.IPI.CST));
    speIPIVBC.Value := Det.Imposto.IPI.vBC;
    speIPIPIPI.Value := Det.Imposto.IPI.pIPI;
    speIPIVIPI.Value := Det.Imposto.IPI.vIPI;
    SelecionarCodigo(cbxPISCST, CSTPISToStr(Det.Imposto.PIS.CST));
    spePISVBC.Value := Det.Imposto.PIS.vBC;
    spePISPPIS.Value := Det.Imposto.PIS.pPIS;
    spePISVPIS.Value := Det.Imposto.PIS.vPIS;
    SelecionarCodigo(cbxCOFINSCST, CSTCOFINSToStr(Det.Imposto.COFINS.CST));
    speCOFINSVBC.Value := Det.Imposto.COFINS.vBC;
    speCOFINSPCOFINS.Value := Det.Imposto.COFINS.pCOFINS;
    speCOFINSVCOFINS.Value := Det.Imposto.COFINS.vCOFINS;
    SelecionarCodigo(cbxIBSCBSCST, CSTIBSCBSToStr(Det.Imposto.IBSCBS.CST));
    edtIBSCBSCClassTrib.Text := cClassTribToStr(Det.Imposto.IBSCBS.cClassTrib);
    speIBSCBSVBC.Value := Det.Imposto.IBSCBS.gIBSCBS.vBC;
    speIBSUFPIBSUF.Value := Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.pIBSUF;
    speIBSUFVIBSUF.Value := Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.vIBSUF;
    speIBSMunPIBSMun.Value := Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.pIBSMun;
    speIBSMunVIBSMun.Value := Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.vIBSMun;
    speCBSPCBS.Value := Det.Imposto.IBSCBS.gIBSCBS.gCBS.pCBS;
    speCBSVCBS.Value := Det.Imposto.IBSCBS.gIBSCBS.gCBS.vCBS;
    speDevolPDevol.Value := Det.pDevol;
    speDevolVIPIDevol.Value := Det.vIPIDevol;
    SelecionarCodigo(cbxICMSCST, CSTICMSToStr(Det.Imposto.ICMS.CST));
    SelecionarCodigo(cbxICMSCSOSN, CSOSNIcmsToStr(Det.Imposto.ICMS.CSOSN));
    // sem desoneração o motivo não é gerado no XML
    if Det.Imposto.ICMS.vICMSDeson > 0 then
      SelecionarCodigo(cbxICMSMotDesICMS, motDesICMSToStr(Det.Imposto.ICMS.motDesICMS))
    else
      cbxICMSMotDesICMS.ItemIndex := 0;
  finally
    FCarregando := Anterior;
  end;
end;

procedure TfrmEmissaoNFe.LerItem(Det: TDetCollectionItem);
var
  Ok: Boolean;
begin
  Det.Prod.cProd := Trim(edtProdCProd.Text);
  Det.Prod.cEAN := Trim(edtProdCEAN.Text);
  Det.Prod.xProd := Trim(edtProdXProd.Text);
  Det.Prod.NCM := Trim(edtProdNCM.Text);
  Det.Prod.CEST := Trim(edtProdCEST.Text);
  Det.Prod.CFOP := Trim(edtProdCFOP.Text);
  Det.Prod.uCom := Trim(edtProdUCom.Text);
  Det.Prod.qCom := speProdQCom.Value;
  Det.Prod.vUnCom := speProdVUnCom.Value;
  Det.Prod.vProd := speProdVProd.Value;
  Det.Prod.cBenef := Trim(edtProdCBenef.Text);
  if chkProdIndTot.Checked then
    Det.Prod.IndTot := itSomaTotalNFe
  else
    Det.Prod.IndTot := itNaoSomaTotalNFe;
  Det.Prod.cEANTrib := Trim(edtProdCEANTrib.Text);
  Det.Prod.uTrib := Trim(edtProdUTrib.Text);
  Det.Prod.qTrib := speProdQTrib.Value;
  Det.Prod.vUnTrib := speProdVUnTrib.Value;
  Det.Prod.vFrete := speProdVFrete.Value;
  Det.Prod.vSeg := speProdVSeg.Value;
  Det.Prod.vDesc := speProdVDesc.Value;
  Det.Prod.vOutro := speProdVOutro.Value;
  Det.Prod.xPed := Trim(edtProdXPed.Text);
  Det.Prod.nItemPed := Trim(edtProdNItemPed.Text);
  Det.infAdProd := Trim(edtProdInfAdProd.Text);
  if cbxICMSOrig.ItemIndex >= 0 then
    Det.Imposto.ICMS.orig := StrToOrig(Ok, CodigoSelecionado(cbxICMSOrig));
  if cbxICMSModBC.ItemIndex >= 0 then
    Det.Imposto.ICMS.modBC := StrTomodBC(Ok, CodigoSelecionado(cbxICMSModBC));
  Det.Imposto.ICMS.pRedBC := speICMSPRedBC.Value;
  Det.Imposto.ICMS.vBC := speICMSVBC.Value;
  Det.Imposto.ICMS.pICMS := speICMSPICMS.Value;
  Det.Imposto.ICMS.vICMS := speICMSVICMS.Value;
  Det.Imposto.ICMS.pFCP := speICMSPFCP.Value;
  Det.Imposto.ICMS.vFCP := speICMSVFCP.Value;
  if cbxICMSModBCST.ItemIndex >= 0 then
    Det.Imposto.ICMS.modBCST := StrTomodBCST(Ok, CodigoSelecionado(cbxICMSModBCST));
  Det.Imposto.ICMS.pMVAST := speICMSPMVAST.Value;
  Det.Imposto.ICMS.pRedBCST := speICMSPRedBCST.Value;
  Det.Imposto.ICMS.vBCST := speICMSVBCST.Value;
  Det.Imposto.ICMS.pICMSST := speICMSPICMSST.Value;
  Det.Imposto.ICMS.vICMSST := speICMSVICMSST.Value;
  Det.Imposto.ICMS.pCredSN := speICMSPCredSN.Value;
  Det.Imposto.ICMS.vCredICMSSN := speICMSVCredICMSSN.Value;
  Det.Imposto.ICMS.vICMSDeson := speICMSVICMSDeson.Value;
  Det.Imposto.IPI.cEnq := Trim(edtIPICEnq.Text);
  if cbxIPICST.ItemIndex >= 0 then
    Det.Imposto.IPI.CST := StrToCSTIPI(Ok, CodigoSelecionado(cbxIPICST));
  Det.Imposto.IPI.vBC := speIPIVBC.Value;
  Det.Imposto.IPI.pIPI := speIPIPIPI.Value;
  Det.Imposto.IPI.vIPI := speIPIVIPI.Value;
  if cbxPISCST.ItemIndex >= 0 then
    Det.Imposto.PIS.CST := StrToCSTPIS(Ok, CodigoSelecionado(cbxPISCST));
  Det.Imposto.PIS.vBC := spePISVBC.Value;
  Det.Imposto.PIS.pPIS := spePISPPIS.Value;
  Det.Imposto.PIS.vPIS := spePISVPIS.Value;
  if cbxCOFINSCST.ItemIndex >= 0 then
    Det.Imposto.COFINS.CST := StrToCSTCOFINS(Ok, CodigoSelecionado(cbxCOFINSCST));
  Det.Imposto.COFINS.vBC := speCOFINSVBC.Value;
  Det.Imposto.COFINS.pCOFINS := speCOFINSPCOFINS.Value;
  Det.Imposto.COFINS.vCOFINS := speCOFINSVCOFINS.Value;
  if cbxIBSCBSCST.ItemIndex >= 0 then
    Det.Imposto.IBSCBS.CST := StrToCSTIBSCBS(CodigoSelecionado(cbxIBSCBSCST));
  Det.Imposto.IBSCBS.cClassTrib := StrTocClassTrib(Trim(edtIBSCBSCClassTrib.Text));
  Det.Imposto.IBSCBS.gIBSCBS.vBC := speIBSCBSVBC.Value;
  Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.pIBSUF := speIBSUFPIBSUF.Value;
  Det.Imposto.IBSCBS.gIBSCBS.gIBSUF.vIBSUF := speIBSUFVIBSUF.Value;
  Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.pIBSMun := speIBSMunPIBSMun.Value;
  Det.Imposto.IBSCBS.gIBSCBS.gIBSMun.vIBSMun := speIBSMunVIBSMun.Value;
  Det.Imposto.IBSCBS.gIBSCBS.gCBS.pCBS := speCBSPCBS.Value;
  Det.Imposto.IBSCBS.gIBSCBS.gCBS.vCBS := speCBSVCBS.Value;
  Det.pDevol := speDevolPDevol.Value;
  Det.vIPIDevol := speDevolVIPIDevol.Value;
  // CST e CSOSN dependem do regime do emitente: só o combo visível vale
  if EhSimplesNacional(FEmissao.NFe) then
  begin
    if cbxICMSCSOSN.ItemIndex >= 0 then
      Det.Imposto.ICMS.CSOSN := StrToCSOSNIcms(Ok, CodigoSelecionado(cbxICMSCSOSN));
  end
  else if cbxICMSCST.ItemIndex >= 0 then
    Det.Imposto.ICMS.CST := StrToCSTICMS(Ok, CodigoSelecionado(cbxICMSCST));
  if CodigoSelecionado(cbxICMSMotDesICMS) <> '' then
    Det.Imposto.ICMS.motDesICMS := StrTomotDesICMS(Ok, CodigoSelecionado(cbxICMSMotDesICMS));
end;

procedure TfrmEmissaoNFe.CarregarGradeItens;
var
  I: integer;
begin
  grdItens.RowCount := FEmissao.NFe.Det.Count + grdItens.FixedRows;
  for I := 0 to FEmissao.NFe.Det.Count - 1 do
    AtualizarLinhaItem(I);
end;

procedure TfrmEmissaoNFe.AtualizarLinhaItem(Index: integer);
var
  Prod: TProd;
  Linha: integer;
begin
  if (Index < 0) or (Index >= FEmissao.NFe.Det.Count) then
    Exit;
  Prod := FEmissao.NFe.Det[Index].Prod;
  Linha := Index + grdItens.FixedRows;
  grdItens.Cells[COL_ITEM_NITEM, Linha] := IntToStr(Prod.nItem);
  grdItens.Cells[1, Linha] := Prod.cProd;
  grdItens.Cells[2, Linha] := Prod.xProd;
  grdItens.Cells[3, Linha] := Prod.NCM;
  grdItens.Cells[4, Linha] := Prod.CFOP;
  grdItens.Cells[5, Linha] := Prod.uCom;
  grdItens.Cells[6, Linha] := TextoDoValor(Prod.qCom, 4);
  grdItens.Cells[7, Linha] := TextoDoValor(Prod.vUnCom, 4);
  grdItens.Cells[8, Linha] := TextoDoValor(Prod.vProd);
end;

procedure TfrmEmissaoNFe.GravarItemAtual;
begin
  if FCarregando then
    Exit;
  if (FItemAtual < 0) or (FItemAtual >= FEmissao.NFe.Det.Count) then
    Exit;
  LerItem(FEmissao.NFe.Det[FItemAtual]);
  AtualizarLinhaItem(FItemAtual);
end;

procedure TfrmEmissaoNFe.SelecionarItem(Index: integer);
var
  Anterior: Boolean;
begin
  if Index <> FItemAtual then
    GravarItemAtual;
  FItemAtual := Index;
  if (Index < 0) or (Index >= FEmissao.NFe.Det.Count) then
  begin
    FItemAtual := -1;
    Exit;
  end;
  Anterior := FCarregando;
  FCarregando := True;
  try
    grdItens.Row := Index + grdItens.FixedRows;
  finally
    FCarregando := Anterior;
  end;
  CarregarItem(FEmissao.NFe.Det[Index]);
end;

procedure TfrmEmissaoNFe.ExcluirItem(Index: integer);
begin
  if (Index < 0) or (Index >= FEmissao.NFe.Det.Count) then
    Exit;
  FEmissao.NFe.Det.Delete(Index);
  FEmissao.RenumerarItens;
  // o item excluído não deve ser gravado de volta pela seleção seguinte
  FItemAtual := -1;
  CarregarGradeItens;
  SelecionarItem(Min(Index, FEmissao.NFe.Det.Count - 1));
  AjustarTela;
end;

procedure TfrmEmissaoNFe.grdItensBeforeSelection(Sender: TObject; aCol, aRow: Integer);
begin
  GravarItemAtual;
end;

procedure TfrmEmissaoNFe.grdItensSelection(Sender: TObject; aCol, aRow: Integer);
begin
  if FCarregando then
    Exit;
  SelecionarItem(aRow - grdItens.FixedRows);
end;

procedure TfrmEmissaoNFe.CarregarVolumes(Nota: TNFe);
var
  I, Linha: integer;
begin
  grdVolumes.RowCount := Nota.Transp.Vol.Count + grdVolumes.FixedRows;
  for I := 0 to Nota.Transp.Vol.Count - 1 do
  begin
    Linha := I + grdVolumes.FixedRows;
    grdVolumes.Cells[0, Linha] := IntToStr(Nota.Transp.Vol[I].qVol);
    grdVolumes.Cells[1, Linha] := Nota.Transp.Vol[I].esp;
    grdVolumes.Cells[2, Linha] := Nota.Transp.Vol[I].marca;
    grdVolumes.Cells[3, Linha] := Nota.Transp.Vol[I].nVol;
    grdVolumes.Cells[4, Linha] := TextoDoValor(Nota.Transp.Vol[I].pesoL, 3);
    grdVolumes.Cells[5, Linha] := TextoDoValor(Nota.Transp.Vol[I].pesoB, 3);
  end;
end;

procedure TfrmEmissaoNFe.LerVolumes(Nota: TNFe);
var
  Linha: integer;
  Vol: TVolCollectionItem;
begin
  // a grade só edita os campos principais; lacres de volumes carregados do XML não são mantidos
  Nota.Transp.Vol.Clear;
  for Linha := grdVolumes.FixedRows to grdVolumes.RowCount - 1 do
  begin
    if LinhaVazia(grdVolumes, Linha) then
      Continue;
    Vol := Nota.Transp.Vol.New;
    Vol.qVol := StrToIntDef(Trim(grdVolumes.Cells[0, Linha]), 0);
    Vol.esp := Trim(grdVolumes.Cells[1, Linha]);
    Vol.marca := Trim(grdVolumes.Cells[2, Linha]);
    Vol.nVol := Trim(grdVolumes.Cells[3, Linha]);
    Vol.pesoL := ValorDoTexto(grdVolumes.Cells[4, Linha]);
    Vol.pesoB := ValorDoTexto(grdVolumes.Cells[5, Linha]);
  end;
end;

procedure TfrmEmissaoNFe.CarregarPagamentos(Nota: TNFe);
var
  I, Linha: integer;
  Pag: TpagCollectionItem;
begin
  grdPagamentos.RowCount := Nota.pag.Count + grdPagamentos.FixedRows;
  for I := 0 to Nota.pag.Count - 1 do
  begin
    Pag := Nota.pag[I];
    Linha := I + grdPagamentos.FixedRows;
    grdPagamentos.Cells[COL_PAG_INDPAG, Linha] :=
      TextoDoCodigo(grdPagamentos.Columns[COL_PAG_INDPAG].PickList, IndpagToStrEX(Pag.indPag));
    grdPagamentos.Cells[COL_PAG_TPAG, Linha] :=
      TextoDoCodigo(grdPagamentos.Columns[COL_PAG_TPAG].PickList, FormaPagamentoToStr(Pag.tPag));
    grdPagamentos.Cells[COL_PAG_XPAG, Linha] := Pag.xPag;
    grdPagamentos.Cells[COL_PAG_VPAG, Linha] := TextoDoValor(Pag.vPag);
    if Pag.tpIntegra = tiNaoInformado then
    begin
      grdPagamentos.Cells[COL_PAG_TPINTEGRA, Linha] := '';
      grdPagamentos.Cells[COL_PAG_TBAND, Linha] := '';
    end
    else
    begin
      grdPagamentos.Cells[COL_PAG_TPINTEGRA, Linha] :=
        TextoDoCodigo(grdPagamentos.Columns[COL_PAG_TPINTEGRA].PickList, tpIntegraToStr(Pag.tpIntegra));
      grdPagamentos.Cells[COL_PAG_TBAND, Linha] :=
        TextoDoCodigo(grdPagamentos.Columns[COL_PAG_TBAND].PickList, BandeiraCartaoToStr(Pag.tBand));
    end;
    grdPagamentos.Cells[COL_PAG_CNPJ, Linha] := Pag.CNPJ;
    grdPagamentos.Cells[COL_PAG_CAUT, Linha] := Pag.cAut;
  end;
end;

procedure TfrmEmissaoNFe.LerPagamentos(Nota: TNFe);
var
  Linha: integer;
  Pag: TpagCollectionItem;
  Codigo: string;
  Ok: Boolean;
begin
  Nota.pag.Clear;
  for Linha := grdPagamentos.FixedRows to grdPagamentos.RowCount - 1 do
  begin
    if LinhaVazia(grdPagamentos, Linha) then
      Continue;
    Pag := Nota.pag.New;
    Codigo := CodigoDoTexto(grdPagamentos.Cells[COL_PAG_INDPAG, Linha]);
    if Codigo <> '' then
      Pag.indPag := StrToIndpagEX(Codigo);
    Pag.tPag := StrToFormaPagamento(Ok, CodigoDoTexto(grdPagamentos.Cells[COL_PAG_TPAG, Linha]));
    Pag.xPag := Trim(grdPagamentos.Cells[COL_PAG_XPAG, Linha]);
    Pag.vPag := ValorDoTexto(grdPagamentos.Cells[COL_PAG_VPAG, Linha]);
    Codigo := CodigoDoTexto(grdPagamentos.Cells[COL_PAG_TPINTEGRA, Linha]);
    if Codigo <> '' then
    begin
      Pag.tpIntegra := StrTotpIntegra(Ok, Codigo);
      Pag.CNPJ := OnlyNumber(grdPagamentos.Cells[COL_PAG_CNPJ, Linha]);
      Codigo := CodigoDoTexto(grdPagamentos.Cells[COL_PAG_TBAND, Linha]);
      if Codigo <> '' then
        Pag.tBand := StrToBandeiraCartao(Ok, Codigo);
      Pag.cAut := Trim(grdPagamentos.Cells[COL_PAG_CAUT, Linha]);
    end;
  end;
end;

procedure TfrmEmissaoNFe.CarregarDuplicatas(Nota: TNFe);
var
  I, Linha: integer;
begin
  grdDuplicatas.RowCount := Nota.Cobr.Dup.Count + grdDuplicatas.FixedRows;
  for I := 0 to Nota.Cobr.Dup.Count - 1 do
  begin
    Linha := I + grdDuplicatas.FixedRows;
    grdDuplicatas.Cells[0, Linha] := Nota.Cobr.Dup[I].nDup;
    grdDuplicatas.Cells[1, Linha] := TextoDaData(Nota.Cobr.Dup[I].dVenc);
    grdDuplicatas.Cells[2, Linha] := TextoDoValor(Nota.Cobr.Dup[I].vDup);
  end;
end;

procedure TfrmEmissaoNFe.LerDuplicatas(Nota: TNFe);
var
  Linha: integer;
  Dup: TDupCollectionItem;
begin
  Nota.Cobr.Dup.Clear;
  for Linha := grdDuplicatas.FixedRows to grdDuplicatas.RowCount - 1 do
  begin
    if LinhaVazia(grdDuplicatas, Linha) then
      Continue;
    Dup := Nota.Cobr.Dup.New;
    Dup.nDup := Trim(grdDuplicatas.Cells[0, Linha]);
    Dup.dVenc := DataDoTexto(grdDuplicatas.Cells[1, Linha]);
    Dup.vDup := ValorDoTexto(grdDuplicatas.Cells[2, Linha]);
  end;
end;

procedure TfrmEmissaoNFe.CarregarReferencias(Nota: TNFe);
var
  I, Linha, Tipo: integer;
  Ref: TNFrefCollectionItem;
begin
  grdReferencias.RowCount := Nota.Ide.NFref.Count + grdReferencias.FixedRows;
  for I := 0 to Nota.Ide.NFref.Count - 1 do
  begin
    Ref := Nota.Ide.NFref[I];
    Linha := I + grdReferencias.FixedRows;
    grdReferencias.Rows[Linha].Clear;
    if Ref.refNFe <> '' then
    begin
      Tipo := REF_NFE;
      grdReferencias.Cells[COL_REF_CHAVE, Linha] := Ref.refNFe;
    end
    else if Ref.refCTe <> '' then
    begin
      Tipo := REF_CTE;
      grdReferencias.Cells[COL_REF_CHAVE, Linha] := Ref.refCTe;
    end
    else if Ref.RefNF.nNF > 0 then
    begin
      Tipo := REF_NF;
      grdReferencias.Cells[COL_REF_CUF, Linha] := IntToStr(Ref.RefNF.cUF);
      grdReferencias.Cells[COL_REF_AAMM, Linha] := Ref.RefNF.AAMM;
      grdReferencias.Cells[COL_REF_CNPJCPF, Linha] := Ref.RefNF.CNPJ;
      grdReferencias.Cells[COL_REF_MODELO, Linha] := IntToStr(Ref.RefNF.modelo);
      grdReferencias.Cells[COL_REF_SERIE, Linha] := IntToStr(Ref.RefNF.serie);
      grdReferencias.Cells[COL_REF_NNF, Linha] := IntToStr(Ref.RefNF.nNF);
    end
    else if Ref.RefNFP.nNF > 0 then
    begin
      Tipo := REF_NFP;
      grdReferencias.Cells[COL_REF_CUF, Linha] := IntToStr(Ref.RefNFP.cUF);
      grdReferencias.Cells[COL_REF_AAMM, Linha] := Ref.RefNFP.AAMM;
      grdReferencias.Cells[COL_REF_CNPJCPF, Linha] := Ref.RefNFP.CNPJCPF;
      grdReferencias.Cells[COL_REF_IE, Linha] := Ref.RefNFP.IE;
      grdReferencias.Cells[COL_REF_MODELO, Linha] := Ref.RefNFP.modelo;
      grdReferencias.Cells[COL_REF_SERIE, Linha] := IntToStr(Ref.RefNFP.serie);
      grdReferencias.Cells[COL_REF_NNF, Linha] := IntToStr(Ref.RefNFP.nNF);
    end
    else
    begin
      Tipo := REF_ECF;
      grdReferencias.Cells[COL_REF_MODELO, Linha] := ECFModRefToStr(Ref.RefECF.modelo);
      grdReferencias.Cells[COL_REF_NECF, Linha] := Ref.RefECF.nECF;
      grdReferencias.Cells[COL_REF_NCOO, Linha] := Ref.RefECF.nCOO;
    end;
    grdReferencias.Cells[COL_REF_TIPO, Linha] := grdReferencias.Columns[COL_REF_TIPO].PickList[Tipo];
  end;
end;

procedure TfrmEmissaoNFe.LerReferencias(Nota: TNFe);
var
  Linha: integer;
  Ref: TNFrefCollectionItem;
  Ok: Boolean;
begin
  Nota.Ide.NFref.Clear;
  for Linha := grdReferencias.FixedRows to grdReferencias.RowCount - 1 do
  begin
    if LinhaVazia(grdReferencias, Linha) then
      Continue;
    Ref := Nota.Ide.NFref.New;
    case grdReferencias.Columns[COL_REF_TIPO].PickList.IndexOf(grdReferencias.Cells[COL_REF_TIPO, Linha]) of
      REF_CTE:
        Ref.refCTe := OnlyNumber(grdReferencias.Cells[COL_REF_CHAVE, Linha]);
      REF_NF:
      begin
        Ref.RefNF.cUF := StrToIntDef(Trim(grdReferencias.Cells[COL_REF_CUF, Linha]), 0);
        Ref.RefNF.AAMM := Trim(grdReferencias.Cells[COL_REF_AAMM, Linha]);
        Ref.RefNF.CNPJ := OnlyNumber(grdReferencias.Cells[COL_REF_CNPJCPF, Linha]);
        Ref.RefNF.modelo := StrToIntDef(Trim(grdReferencias.Cells[COL_REF_MODELO, Linha]), 1);
        Ref.RefNF.serie := StrToIntDef(Trim(grdReferencias.Cells[COL_REF_SERIE, Linha]), 0);
        Ref.RefNF.nNF := StrToIntDef(Trim(grdReferencias.Cells[COL_REF_NNF, Linha]), 0);
      end;
      REF_NFP:
      begin
        Ref.RefNFP.cUF := StrToIntDef(Trim(grdReferencias.Cells[COL_REF_CUF, Linha]), 0);
        Ref.RefNFP.AAMM := Trim(grdReferencias.Cells[COL_REF_AAMM, Linha]);
        Ref.RefNFP.CNPJCPF := OnlyNumber(grdReferencias.Cells[COL_REF_CNPJCPF, Linha]);
        Ref.RefNFP.IE := Trim(grdReferencias.Cells[COL_REF_IE, Linha]);
        Ref.RefNFP.modelo := Trim(grdReferencias.Cells[COL_REF_MODELO, Linha]);
        Ref.RefNFP.serie := StrToIntDef(Trim(grdReferencias.Cells[COL_REF_SERIE, Linha]), 0);
        Ref.RefNFP.nNF := StrToIntDef(Trim(grdReferencias.Cells[COL_REF_NNF, Linha]), 0);
      end;
      REF_ECF:
      begin
        Ref.RefECF.modelo := StrToECFModRef(Ok, Trim(grdReferencias.Cells[COL_REF_MODELO, Linha]));
        Ref.RefECF.nECF := Trim(grdReferencias.Cells[COL_REF_NECF, Linha]);
        Ref.RefECF.nCOO := Trim(grdReferencias.Cells[COL_REF_NCOO, Linha]);
      end;
    else
      // sem tipo escolhido, a chave de acesso é tratada como NF-e/NFC-e
      Ref.refNFe := OnlyNumber(grdReferencias.Cells[COL_REF_CHAVE, Linha]);
    end;
  end;
end;

procedure TfrmEmissaoNFe.pgcNFeChange(Sender: TObject);
begin
  if pgcNFe.ActivePage <> tabTotais then
    Exit;
  LerTela;
  FEmissao.CalcularTotais;
  CarregarTotais(FEmissao.NFe);
end;

procedure TfrmEmissaoNFe.cbxIdeModeloChange(Sender: TObject);
begin
  if FCarregando then
    Exit;
  LerTela;
  FEmissao.AplicarRegrasModelo;
  CarregarTela;
end;

procedure TfrmEmissaoNFe.cbxIdeFinNFeChange(Sender: TObject);
begin
  if FCarregando then
    Exit;
  LerTela;
  FEmissao.AplicarRegrasFinalidade;
  CarregarTela;
  // complementar e devolução exigem documento referenciado (254, 321)
  if FEmissao.NFe.Ide.finNFe in [fnComplementar, fnDevolucao] then
    pgcNFe.ActivePage := tabReferencias;
end;

procedure TfrmEmissaoNFe.cbxDestUFChange(Sender: TObject);
begin
  if FCarregando then
    Exit;
  LerTela;
  FEmissao.DefinirDestinoOperacao;
  CarregarTela;
end;

procedure TfrmEmissaoNFe.cbxEmitCRTChange(Sender: TObject);
begin
  if FCarregando then
    Exit;
  LerTela;
  CarregarTela;
end;

procedure TfrmEmissaoNFe.cbxAjustarTelaChange(Sender: TObject);
begin
  if FCarregando then
    Exit;
  LerTela;
  AjustarTela;
end;

procedure TfrmEmissaoNFe.btnEmitRecarregarClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  LerTela;
  Ini := TIniFile.Create(FArquivoIni);
  try
    FEmissao.PreencherEmitente(Ini);
  finally
    Ini.Free;
  end;
  CarregarTela;
end;

procedure TfrmEmissaoNFe.btnItemNovoClick(Sender: TObject);
begin
  // CFOP e CST padrão do novo item dependem do tipo, destino e regime da tela
  LerTela;
  FEmissao.NovoItem;
  FItemAtual := -1;
  CarregarGradeItens;
  SelecionarItem(FEmissao.NFe.Det.Count - 1);
  AjustarTela;
  pgcItem.ActivePage := tabItemProduto;
end;

procedure TfrmEmissaoNFe.btnItemExcluirClick(Sender: TObject);
begin
  if FItemAtual < 0 then
    Exit;
  if MessageDlg(Format(MSG_EXCLUIR_ITEM, [FItemAtual + 1]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  ExcluirItem(FItemAtual);
end;

procedure TfrmEmissaoNFe.btnItemCalcularClick(Sender: TObject);
begin
  if FItemAtual < 0 then
    Exit;
  LerTela;
  FEmissao.CalcularItem(FEmissao.NFe.Det[FItemAtual]);
  SelecionarItem(FItemAtual);
  AtualizarLinhaItem(FItemAtual);
end;

procedure TfrmEmissaoNFe.btnVolAdicionarClick(Sender: TObject);
begin
  grdVolumes.RowCount := grdVolumes.RowCount + 1;
end;

procedure TfrmEmissaoNFe.btnVolRemoverClick(Sender: TObject);
begin
  RemoverLinhaAtual(grdVolumes);
end;

procedure TfrmEmissaoNFe.btnPagAdicionarClick(Sender: TObject);
begin
  grdPagamentos.RowCount := grdPagamentos.RowCount + 1;
end;

procedure TfrmEmissaoNFe.btnPagRemoverClick(Sender: TObject);
begin
  RemoverLinhaAtual(grdPagamentos);
end;

procedure TfrmEmissaoNFe.btnDupAdicionarClick(Sender: TObject);
begin
  grdDuplicatas.RowCount := grdDuplicatas.RowCount + 1;
end;

procedure TfrmEmissaoNFe.btnDupRemoverClick(Sender: TObject);
begin
  RemoverLinhaAtual(grdDuplicatas);
end;

procedure TfrmEmissaoNFe.btnRefAdicionarClick(Sender: TObject);
begin
  grdReferencias.RowCount := grdReferencias.RowCount + 1;
end;

procedure TfrmEmissaoNFe.btnRefRemoverClick(Sender: TObject);
begin
  RemoverLinhaAtual(grdReferencias);
end;

procedure TfrmEmissaoNFe.AbrirArquivo(const Arquivo: string);
begin
  FEmissao.CarregarXML(Arquivo);
  FItemAtual := -1;
  CarregarTela;
end;

procedure TfrmEmissaoNFe.SalvarArquivo(const Arquivo: string);
begin
  LerTela;
  FEmissao.CalcularTotais;
  FEmissao.SalvarXML(Arquivo);
  // GerarXML preenche cNF e cDV ao montar a chave
  CarregarTela;
end;

function TfrmEmissaoNFe.ValidarNota: Boolean;
var
  Erros, Avisos: TStringList;
begin
  LerTela;
  FEmissao.CalcularTotais;
  Erros := TStringList.Create;
  Avisos := TStringList.Create;
  try
    Result := FEmissao.Validar(Erros, Avisos);
    mmoValidacao.Lines.BeginUpdate;
    try
      mmoValidacao.Clear;
      mmoValidacao.Lines.Add(Format('Erros (%d):', [Erros.Count]));
      mmoValidacao.Lines.AddStrings(Erros);
      mmoValidacao.Lines.Add('');
      mmoValidacao.Lines.Add(Format('Avisos (%d):', [Avisos.Count]));
      mmoValidacao.Lines.AddStrings(Avisos);
    finally
      mmoValidacao.Lines.EndUpdate;
    end;
    CarregarTela;
    if (Erros.Count > 0) or (Avisos.Count > 0) then
      pgcNFe.ActivePage := tabValidacao;
  finally
    Avisos.Free;
    Erros.Free;
  end;
end;

procedure TfrmEmissaoNFe.tbtNovoClick(Sender: TObject);
begin
  if MessageDlg(MSG_NOVA_NOTA, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  NovaNotaDaConfiguracao;
end;

procedure TfrmEmissaoNFe.tbtAbrirClick(Sender: TObject);
begin
  if not dlgAbrirXML.Execute then
    Exit;
  AbrirArquivo(dlgAbrirXML.FileName);
end;

procedure TfrmEmissaoNFe.tbtSalvarClick(Sender: TObject);
begin
  dlgSalvarXML.FileName := Format('nfe-%d-%d.xml', [speIdeSerie.Value, speIdeNNF.Value]);
  if not dlgSalvarXML.Execute then
    Exit;
  SalvarArquivo(dlgSalvarXML.FileName);
  MessageDlg(Format(MSG_XML_SALVO, [dlgSalvarXML.FileName]), mtInformation, [mbOK], 0);
end;

procedure TfrmEmissaoNFe.tbtValidarClick(Sender: TObject);
begin
  if ValidarNota then
    MessageDlg(MSG_SEM_PENDENCIAS, mtInformation, [mbOK], 0)
  else
    MessageDlg(MSG_COM_PENDENCIAS, mtWarning, [mbOK], 0);
end;

procedure TfrmEmissaoNFe.tbtEmitirClick(Sender: TObject);
var
  Resultado: TResultadoEmissao;
begin
  if not ValidarNota then
  begin
    MessageDlg(MSG_COM_PENDENCIAS, mtWarning, [mbOK], 0);
    Exit;
  end;
  if MessageDlg(Format(MSG_CONFIRMAR_EMISSAO, [cbxIdeModelo.Text, speIdeNNF.Value, speIdeSerie.Value,
    cbxIdeTpAmb.Text]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  Screen.Cursor := crHourGlass;
  try
    Resultado := FEmissao.Emitir;
  finally
    Screen.Cursor := crDefault;
  end;
  CarregarTela;
  if Resultado.Autorizada then
    MessageDlg(Format(MSG_AUTORIZADA, [FormatarChaveAcesso(Resultado.Chave), Resultado.Protocolo]),
      mtInformation, [mbOK], 0)
  else
    MessageDlg(Format(MSG_NAO_AUTORIZADA, [Resultado.cStat, Resultado.xMotivo]), mtError, [mbOK], 0);
end;

end.
