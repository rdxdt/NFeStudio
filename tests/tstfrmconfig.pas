unit tstfrmconfig;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, IniFiles, ufrmconfig;

type

  { TfrmConfigTeste }

  // expõe a leitura/gravação da seção Emitente sem abrir o form em modal
  TfrmConfigTeste = class(TfrmConfig)
  public
    procedure Carregar(Ini: TCustomIniFile);
    procedure Salvar(Ini: TCustomIniFile);
  end;

  { TTesteFrmConfig }

  TTesteFrmConfig = class(TTestCase)
  private
    FForm: TfrmConfigTeste;
    FIni: TMemIniFile;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCarregarEmitente;
    procedure TestSalvarEmitente;
    procedure TestEmitenteVazio;
    procedure TestCNPJAlfanumerico;
  end;

implementation

uses
  Forms;

const
  SECAO = 'Emitente';

{ TfrmConfigTeste }

procedure TfrmConfigTeste.Carregar(Ini: TCustomIniFile);
begin
  CarregarEmitente(Ini);
end;

procedure TfrmConfigTeste.Salvar(Ini: TCustomIniFile);
begin
  SalvarEmitente(Ini);
end;

{ TTesteFrmConfig }

procedure TTesteFrmConfig.SetUp;
begin
  // o executor de testes não inicializa o widgetset, necessário para criar forms
  if not (AppInitialized in Application.Flags) then
    Application.Initialize;
  FForm := TfrmConfigTeste.Create(nil);
  FIni := TMemIniFile.Create('');
end;

procedure TTesteFrmConfig.TearDown;
begin
  FIni.Free;
  FForm.Free;
end;

procedure TTesteFrmConfig.TestCarregarEmitente;
begin
  FIni.WriteString(SECAO, 'CNPJCPF', '12345678000195');
  FIni.WriteString(SECAO, 'IE', '123456789110');
  FIni.WriteString(SECAO, 'RazaoSocial', 'Empresa Teste Ltda');
  FIni.WriteString(SECAO, 'Fantasia', 'Teste');
  FIni.WriteInteger(SECAO, 'CRT', 1);
  FIni.WriteString(SECAO, 'Fone', '1133334444');
  FIni.WriteString(SECAO, 'CEP', '01310100');
  FIni.WriteString(SECAO, 'Logradouro', 'Av. Paulista');
  FIni.WriteString(SECAO, 'Numero', '1000');
  FIni.WriteString(SECAO, 'Complemento', 'Sala 1');
  FIni.WriteString(SECAO, 'Bairro', 'Bela Vista');
  FIni.WriteInteger(SECAO, 'CodMunicipio', 3550308);
  FIni.WriteString(SECAO, 'Municipio', 'São Paulo');
  FIni.WriteString(SECAO, 'UF', 'SP');

  FForm.Carregar(FIni);
  AssertEquals('CNPJ formatado', '12.345.678/0001-95', FForm.edtEmitCNPJCPF.Text);
  AssertEquals('IE', '123456789110', FForm.edtEmitIE.Text);
  AssertEquals('razão social', 'Empresa Teste Ltda', FForm.edtEmitRazaoSocial.Text);
  AssertEquals('fantasia', 'Teste', FForm.edtEmitFantasia.Text);
  AssertEquals('CRT 1 = primeiro item', 0, FForm.cbxEmitCRT.ItemIndex);
  AssertEquals('fone', '1133334444', FForm.edtEmitFone.Text);
  AssertEquals('CEP formatado', '01310-100', FForm.edtEmitCEP.Text);
  AssertEquals('logradouro', 'Av. Paulista', FForm.edtEmitLogradouro.Text);
  AssertEquals('número', '1000', FForm.edtEmitNumero.Text);
  AssertEquals('complemento', 'Sala 1', FForm.edtEmitComplemento.Text);
  AssertEquals('bairro', 'Bela Vista', FForm.edtEmitBairro.Text);
  AssertEquals('cód. município', 3550308, FForm.speEmitCodMunicipio.Value);
  AssertEquals('município', 'São Paulo', FForm.edtEmitMunicipio.Text);
  AssertEquals('UF', 'SP', FForm.cbxEmitUF.Text);
end;

procedure TTesteFrmConfig.TestSalvarEmitente;
begin
  FForm.edtEmitCNPJCPF.Text := '123.456.789-09';
  FForm.edtEmitIE.Text := ' ISENTO ';
  FForm.edtEmitRazaoSocial.Text := 'Produtor Rural';
  FForm.cbxEmitCRT.ItemIndex := 2;
  FForm.edtEmitFone.Text := '(11) 3333-4444';
  FForm.edtEmitCEP.Text := '01310-100';
  FForm.speEmitCodMunicipio.Value := 3550308;
  FForm.cbxEmitUF.ItemIndex := FForm.cbxEmitUF.Items.IndexOf('RJ');

  FForm.Salvar(FIni);
  AssertEquals('CPF sem máscara', '12345678909', FIni.ReadString(SECAO, 'CNPJCPF', ''));
  AssertEquals('IE sem espaços', 'ISENTO', FIni.ReadString(SECAO, 'IE', ''));
  AssertEquals('razão social', 'Produtor Rural', FIni.ReadString(SECAO, 'RazaoSocial', ''));
  AssertEquals('CRT código NF-e', '3', FIni.ReadString(SECAO, 'CRT', ''));
  AssertEquals('fone só dígitos', '1133334444', FIni.ReadString(SECAO, 'Fone', ''));
  AssertEquals('CEP só dígitos', '01310100', FIni.ReadString(SECAO, 'CEP', ''));
  AssertEquals('cód. município', 3550308, FIni.ReadInteger(SECAO, 'CodMunicipio', 0));
  AssertEquals('UF', 'RJ', FIni.ReadString(SECAO, 'UF', ''));
end;

procedure TTesteFrmConfig.TestEmitenteVazio;
begin
  FForm.Carregar(FIni);
  AssertEquals('CNPJ', '', FForm.edtEmitCNPJCPF.Text);
  // FormatarCEP('') do ACBr devolveria '00000-000'
  AssertEquals('CEP', '', FForm.edtEmitCEP.Text);
  AssertEquals('CRT sem seleção', -1, FForm.cbxEmitCRT.ItemIndex);
  AssertEquals('UF sem seleção', -1, FForm.cbxEmitUF.ItemIndex);

  FForm.Salvar(FIni);
  AssertEquals('CRT vazio', '', FIni.ReadString(SECAO, 'CRT', 'x'));
  AssertEquals('CEP vazio', '', FIni.ReadString(SECAO, 'CEP', 'x'));
  AssertEquals('UF vazia', '', FIni.ReadString(SECAO, 'UF', 'x'));
end;

procedure TTesteFrmConfig.TestCNPJAlfanumerico;
begin
  FForm.edtEmitCNPJCPF.Text := '12.abc.345/01de-35';
  FForm.Salvar(FIni);
  AssertEquals('letras preservadas', '12ABC34501DE35', FIni.ReadString(SECAO, 'CNPJCPF', ''));
  FForm.Carregar(FIni);
  AssertEquals('formatado', '12.ABC.345/01DE-35', FForm.edtEmitCNPJCPF.Text);
end;

initialization
  RegisterTest(TTesteFrmConfig);

end.
