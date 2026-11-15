unit tstfrmemissaonfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, IniFiles, ufrmemissaonfe;

type

  { TTesteFrmEmissaoNFe }

  TTesteFrmEmissaoNFe = class(TTestCase)
  private
    FForm: TfrmEmissaoNFe;
    FIni: TMemIniFile;
    FPasta: string;
    procedure PreencherItem;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCodigosDosCombos;
    procedure TestValorDoTexto;
    procedure TestIniciarPreencheEmitente;
    procedure TestTrocarParaNFCe;
    procedure TestFinalidadeDevolucao;
    procedure TestItens;
    procedure TestRegimeDefineCSTouCSOSN;
    procedure TestGradesParaNota;
    procedure TestSalvarEAbrirArquivo;
    procedure TestValidarNotaIncompleta;
    procedure TestUFDestinoDefineOperacao;
  end;

implementation

uses
  Forms, FileUtil, ACBrNFe.Classes, pcnConversao, pcnConversaoNFe, uemissaonfe;

const
  SECAO = 'Emitente';
  CHAVE_REF = '35150905481336000137550010000111291000111298';

{ TTesteFrmEmissaoNFe }

procedure TTesteFrmEmissaoNFe.SetUp;
begin
  // o executor de testes não inicializa o widgetset, necessário para criar forms
  if not (AppInitialized in Application.Flags) then
    Application.Initialize;
  FPasta := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'nfestudio-teste-frmemissao-' +
    IntToStr(GetProcessID) + PathDelim;
  DeleteDirectory(FPasta, False);
  ForceDirectories(FPasta);

  FIni := TMemIniFile.Create('');
  FIni.WriteString(SECAO, 'CNPJCPF', '05481336000137');
  FIni.WriteString(SECAO, 'IE', '687138770110');
  FIni.WriteString(SECAO, 'RazaoSocial', 'D.J. SYSTEM CONSULTORIA LTDA - ME');
  FIni.WriteInteger(SECAO, 'CRT', 3);
  FIni.WriteString(SECAO, 'CEP', '18270000');
  FIni.WriteString(SECAO, 'Logradouro', 'Rua Cel. Aureliano de Camargo');
  FIni.WriteString(SECAO, 'Numero', '973');
  FIni.WriteString(SECAO, 'Bairro', 'Centro');
  FIni.WriteInteger(SECAO, 'CodMunicipio', 3554003);
  FIni.WriteString(SECAO, 'Municipio', 'Tatui');
  FIni.WriteString(SECAO, 'UF', 'SP');

  FForm := TfrmEmissaoNFe.Create(nil);
  FForm.Iniciar(FIni);
end;

procedure TTesteFrmEmissaoNFe.TearDown;
begin
  FForm.Free;
  FIni.Free;
  DeleteDirectory(FPasta, False);
end;

procedure TTesteFrmEmissaoNFe.PreencherItem;
begin
  FForm.btnItemNovoClick(nil);
  FForm.edtProdCProd.Text := '001';
  FForm.edtProdXProd.Text := 'PRODUTO DE TESTE';
  FForm.edtProdNCM.Text := '84713012';
  FForm.edtProdUCom.Text := 'UN';
  FForm.speProdQCom.Value := 2;
  FForm.speProdVUnCom.Value := 10.5;
  FForm.speICMSPICMS.Value := 18;
end;

procedure TTesteFrmEmissaoNFe.TestCodigosDosCombos;
var
  Itens: TStringList;
begin
  AssertEquals('código', '4', CodigoDoTexto('4 - Devolução de mercadoria'));
  AssertEquals('item sem código', '', CodigoDoTexto('Não informado'));
  AssertEquals('descrição com hífen', '99', CodigoDoTexto('99 - Outros - diversos'));
  Itens := TStringList.Create;
  try
    Itens.Add('Não se aplica');
    Itens.Add('01 - Multa e juros');
    AssertEquals('pelo código', 1, IndiceDoCodigo(Itens, '01'));
    AssertEquals('vazio seleciona o item sem código', 0, IndiceDoCodigo(Itens, ''));
    AssertEquals('inexistente', -1, IndiceDoCodigo(Itens, '02'));
  finally
    Itens.Free;
  end;
end;

procedure TTesteFrmEmissaoNFe.TestValorDoTexto;
begin
  AssertEquals('vírgula com milhar', 1234.56, ValorDoTexto('1.234,56'), 0.0001);
  AssertEquals('ponto decimal', 12.5, ValorDoTexto('12.5'), 0.0001);
  AssertEquals('inválido', 0, ValorDoTexto('abc'), 0.0001);
end;

procedure TTesteFrmEmissaoNFe.TestIniciarPreencheEmitente;
begin
  AssertEquals('CNPJ formatado', '05.481.336/0001-37', FForm.edtEmitCNPJCPF.Text);
  AssertEquals('IE', '687138770110', FForm.edtEmitIE.Text);
  AssertEquals('CRT', '3', CodigoSelecionado(FForm.cbxEmitCRT));
  AssertEquals('CEP formatado', '18270-000', FForm.edtEmitCEP.Text);
  AssertEquals('UF', 'SP', FForm.cbxEmitUF.Text);
  AssertEquals('modelo', '55', CodigoSelecionado(FForm.cbxIdeModelo));
  AssertEquals('finalidade', '1', CodigoSelecionado(FForm.cbxIdeFinNFe));
  AssertEquals('município do fato gerador', 3554003, FForm.speIdeCMunFG.Value);
  AssertFalse('sem itens, editor desabilitado', FForm.pgcItem.Enabled);
  AssertFalse('contingência desabilitada', FForm.grpIdeContingencia.Enabled);
end;

procedure TTesteFrmEmissaoNFe.TestTrocarParaNFCe;
begin
  SelecionarCodigo(FForm.cbxIdeTpNF, '0');
  SelecionarCodigo(FForm.cbxIdeModelo, '65');
  FForm.cbxIdeModeloChange(nil);
  AssertEquals('DANFE NFC-e', '4', CodigoSelecionado(FForm.cbxIdeTpImp));
  AssertEquals('consumidor final', '1', CodigoSelecionado(FForm.cbxIdeIndFinal));
  AssertEquals('saída', '1', CodigoSelecionado(FForm.cbxIdeTpNF));
  AssertFalse('sem referências', FForm.tabReferencias.TabVisible);
  AssertFalse('sem IPI', FForm.tabItemIPI.TabVisible);
  AssertFalse('sem cobrança', FForm.grpDuplicatas.Enabled);
  AssertFalse('sem IE do destinatário', FForm.edtDestIE.Enabled);

  SelecionarCodigo(FForm.cbxIdeModelo, '55');
  FForm.cbxIdeModeloChange(nil);
  AssertEquals('DANFE retrato', '1', CodigoSelecionado(FForm.cbxIdeTpImp));
  AssertTrue('referências de volta', FForm.tabReferencias.TabVisible);
end;

procedure TTesteFrmEmissaoNFe.TestFinalidadeDevolucao;
begin
  FForm.btnPagAdicionarClick(nil);
  FForm.grdPagamentos.Cells[1, 1] := '01 - Dinheiro';
  FForm.grdPagamentos.Cells[3, 1] := '10,00';
  SelecionarCodigo(FForm.cbxIdeFinNFe, '4');
  FForm.cbxIdeFinNFeChange(nil);
  AssertEquals('um pagamento', 2, FForm.grdPagamentos.RowCount);
  AssertEquals('sem pagamento', '90', CodigoDoTexto(FForm.grdPagamentos.Cells[1, 1]));
  AssertTrue('vai para as referências', FForm.pgcNFe.ActivePage = FForm.tabReferencias);
  AssertTrue('aba de devolução no item', FForm.tabItemDevolucao.TabVisible);
end;

procedure TTesteFrmEmissaoNFe.TestItens;
var
  Nota: TNFe;
begin
  PreencherItem;
  AssertEquals('linha do item', 2, FForm.grdItens.RowCount);
  AssertTrue('editor habilitado', FForm.pgcItem.Enabled);
  AssertEquals('CFOP padrão', '5102', FForm.edtProdCFOP.Text);
  FForm.btnItemCalcularClick(nil);
  AssertEquals('valor total calculado', 21, FForm.speProdVProd.Value, 0.001);
  AssertEquals('ICMS calculado', 3.78, FForm.speICMSVICMS.Value, 0.001);
  AssertEquals('grade atualizada', 'PRODUTO DE TESTE', FForm.grdItens.Cells[2, 1]);

  FForm.btnItemNovoClick(nil);
  FForm.edtProdCProd.Text := '002';
  AssertEquals('segundo item', 3, FForm.grdItens.RowCount);
  FForm.SelecionarItem(0);
  AssertEquals('primeiro item recarregado', '001', FForm.edtProdCProd.Text);
  FForm.LerTela;
  Nota := FForm.Emissao.NFe;
  AssertEquals('segundo item gravado ao trocar de linha', '002', Nota.Det[1].Prod.cProd);

  FForm.ExcluirItem(0);
  AssertEquals('um item', 1, Nota.Det.Count);
  AssertEquals('renumerado', 1, Nota.Det[0].Prod.nItem);
  AssertEquals('restante selecionado', '002', FForm.edtProdCProd.Text);
end;

procedure TTesteFrmEmissaoNFe.TestRegimeDefineCSTouCSOSN;
begin
  PreencherItem;
  AssertTrue('regime normal: CST', FForm.cbxICMSCST.Visible);
  AssertFalse(FForm.cbxICMSCSOSN.Visible);
  SelecionarCodigo(FForm.cbxEmitCRT, '1');
  FForm.cbxEmitCRTChange(nil);
  AssertTrue('Simples: CSOSN', FForm.cbxICMSCSOSN.Visible);
  AssertFalse(FForm.cbxICMSCST.Visible);
  SelecionarCodigo(FForm.cbxICMSCSOSN, '500');
  FForm.LerTela;
  AssertTrue('CSOSN gravado', FForm.Emissao.NFe.Det[0].Imposto.ICMS.CSOSN = csosn500);
end;

procedure TTesteFrmEmissaoNFe.TestGradesParaNota;
var
  Nota: TNFe;
begin
  FForm.btnRefAdicionarClick(nil);
  FForm.grdReferencias.Cells[0, 1] := 'NF-e / NFC-e';
  FForm.grdReferencias.Cells[1, 1] := CHAVE_REF;
  FForm.btnDupAdicionarClick(nil);
  FForm.grdDuplicatas.Cells[0, 1] := '001';
  FForm.grdDuplicatas.Cells[1, 1] := '15/12/2026';
  FForm.grdDuplicatas.Cells[2, 1] := '50,00';
  FForm.btnVolAdicionarClick(nil);
  FForm.grdVolumes.Cells[0, 1] := '3';
  FForm.grdVolumes.Cells[1, 1] := 'CAIXA';
  FForm.btnPagAdicionarClick(nil);
  FForm.grdPagamentos.Cells[1, 1] := '03 - Cartão de crédito';
  FForm.grdPagamentos.Cells[3, 1] := '50,00';
  FForm.grdPagamentos.Cells[4, 1] := '2 - Não integrado';
  FForm.grdPagamentos.Cells[6, 1] := '02 - Mastercard';
  FForm.LerTela;

  Nota := FForm.Emissao.NFe;
  AssertEquals('referência', CHAVE_REF, Nota.Ide.NFref[0].refNFe);
  AssertEquals('duplicata', '001', Nota.Cobr.Dup[0].nDup);
  AssertEquals('vencimento', EncodeDate(2026, 12, 15), Nota.Cobr.Dup[0].dVenc);
  AssertEquals('valor da duplicata', 50, Nota.Cobr.Dup[0].vDup, 0.001);
  AssertEquals('volumes', 3, Nota.Transp.Vol[0].qVol);
  AssertTrue('cartão de crédito', Nota.pag[0].tPag = fpCartaoCredito);
  AssertTrue('não integrado', Nota.pag[0].tpIntegra = tiPagNaoIntegrado);
  AssertTrue('bandeira', Nota.pag[0].tBand = bcMasterCard);

  FForm.CarregarTela;
  AssertEquals('grade recarregada', '15/12/2026', FForm.grdDuplicatas.Cells[1, 1]);
  AssertEquals('tipo da referência', 'NF-e / NFC-e', FForm.grdReferencias.Cells[0, 1]);
  AssertEquals('bandeira recarregada', '02 - Mastercard', FForm.grdPagamentos.Cells[6, 1]);
end;

procedure TTesteFrmEmissaoNFe.TestSalvarEAbrirArquivo;
var
  Arquivo: string;
begin
  FForm.edtIdeNatOp.Text := 'VENDA DE MERCADORIA';
  FForm.speIdeNNF.Value := 77;
  FForm.mmoInfCpl.Text := 'Observação do teste';
  PreencherItem;
  FForm.btnItemCalcularClick(nil);
  Arquivo := FPasta + 'nota.xml';
  FForm.SalvarArquivo(Arquivo);
  AssertTrue('arquivo gravado', FileExists(Arquivo));
  AssertTrue('cNF preenchido pela chave', FForm.speIdeCNF.Value > 0);

  FForm.Iniciar(FIni);
  AssertEquals('nova nota sem itens', 1, FForm.grdItens.RowCount);
  FForm.AbrirArquivo(Arquivo);
  AssertEquals('natureza', 'VENDA DE MERCADORIA', FForm.edtIdeNatOp.Text);
  AssertEquals('número', 77, FForm.speIdeNNF.Value);
  // RetirarAcentos (padrão do ACBr) remove a acentuação ao gerar o XML
  AssertEquals('informações complementares', 'Observacao do teste', FForm.mmoInfCpl.Text);
  AssertEquals('item carregado', 2, FForm.grdItens.RowCount);
  AssertEquals('ICMS do item', 3.78, FForm.speICMSVICMS.Value, 0.001);
end;

procedure TTesteFrmEmissaoNFe.TestValidarNotaIncompleta;
begin
  AssertFalse('sem destinatário e sem itens', FForm.ValidarNota);
  AssertTrue('aba de validação', FForm.pgcNFe.ActivePage = FForm.tabValidacao);
  AssertTrue('lista os erros', Pos('a nota deve ter ao menos um item', FForm.mmoValidacao.Text) > 0);
end;

procedure TTesteFrmEmissaoNFe.TestUFDestinoDefineOperacao;
begin
  SelecionarCodigo(FForm.cbxIdeIndPres, '2');
  FForm.cbxDestUF.ItemIndex := FForm.cbxDestUF.Items.IndexOf('RJ');
  FForm.cbxDestUFChange(nil);
  AssertEquals('interestadual', '2', CodigoSelecionado(FForm.cbxIdeIdDest));
  FForm.cbxDestUF.ItemIndex := FForm.cbxDestUF.Items.IndexOf('EX');
  FForm.cbxDestUFChange(nil);
  AssertEquals('exterior', '3', CodigoSelecionado(FForm.cbxIdeIdDest));
end;

initialization
  RegisterTest(TTesteFrmEmissaoNFe);

end.
