# ufrmconfig

Formulário de edição do arquivo INI de configuração da aplicação (o mesmo lido pelo `frmMain`;
ver [ufrmmain](ufrmmain.md)).

## TfrmConfig

### Uso

```pascal
if TfrmConfig.Executar(ArquivoIni) then
  // configurações salvas: recarregar no chamador
```

`Executar` cria o form, carrega o INI informado, exibe em modal e libera o form.
Retorna `True` somente se o usuário clicou em **Salvar** (o INI já foi gravado).
O form não aplica as configurações em outros componentes; quem chama é responsável por recarregá-las.

### Leitura e gravação

- Seções `DFe`, `NFe` e `Proxy`: lidas e gravadas por um `TACBrNFe` próprio do form (`ACBrNFe1`)
  via `Configuracoes.LerIni`/`GravarIni`. Assim o formato (inclusive senhas codificadas e chaves
  sem campo na tela, como `DadosPFX`) é idêntico ao usado pelo `frmMain`.
- Seção `PosPrinter`: lida e gravada diretamente no INI, com as mesmas chaves de
  `TfrmMain.GravarConfigPosPrinter`.
- Seção `DANFE`: chave `Componente` (`RL`, `ESCPOS`, `FORTES`, `FORTESA4`), na mesma ordem dos itens de `cbxDANFE`.
- Seção `Emitente`: dados do emissor, lidos e gravados diretamente no INI (ver abaixo).

### Seção `Emitente`

| Chave          | Controle               | Formato gravado                                             |
|----------------|------------------------|-------------------------------------------------------------|
| `CNPJCPF`      | `edtEmitCNPJCPF`       | Sem máscara e em maiúsculas (`OnlyAlphaNum`, preserva o CNPJ alfanumérico); exibido com `FormatarCNPJouCPF` |
| `IE`           | `edtEmitIE`            | Texto (aceita `ISENTO`)                                     |
| `RazaoSocial`  | `edtEmitRazaoSocial`   | Texto                                                       |
| `Fantasia`     | `edtEmitFantasia`      | Texto                                                       |
| `CRT`          | `cbxEmitCRT`           | Código da NF-e (`1` a `4` = `ItemIndex + 1`); vazio sem seleção |
| `Fone`         | `edtEmitFone`          | Somente dígitos                                             |
| `CEP`          | `edtEmitCEP`           | Somente dígitos; exibido com `FormatarCEP` (CEP vazio continua vazio, pois `FormatarCEP('')` devolve `00000-000`) |
| `Logradouro`, `Numero`, `Complemento`, `Bairro` | `edtEmit<Chave>` | Texto                         |
| `CodMunicipio` | `speEmitCodMunicipio`  | Código IBGE (inteiro)                                       |
| `Municipio`    | `edtEmitMunicipio`     | Texto                                                       |
| `UF`           | `cbxEmitUF`            | Sigla; vazio sem seleção                                    |

Os textos são gravados sem espaços nas pontas (`Trim`). Por enquanto, a seção só é lida e gravada pelo
`frmConfig`: nenhum outro ponto da aplicação usa os dados do emitente.

### Controles

| Tipo de configuração | Controle                                              |
|----------------------|-------------------------------------------------------|
| Enumerado            | `TComboBox` (`csDropDownList`), `ItemIndex = Ord(valor)` |
| Pasta                | `TDirectoryEdit` (edit com botão de seleção de diretório) |
| Arquivo              | `TFileNameEdit` (edit com botão de seleção de arquivo) |
| Inteiro              | `TSpinEdit`                                           |
| Booleano             | `TCheckBox`                                           |
| Texto / senha        | `TEdit` (`PasswordChar = '*'` para senhas)            |

**Atenção:** os itens dos comboboxes de enumerados seguem a ordem exata dos tipos do ACBr
(`TpcnModeloDF`, `TpcnVersaoDF`, `TpcnTipoEmissao`, `TpcnVersaoQrCode`, `TForcarGeracaoTag`,
`TSSLCryptLib`, `TSSLHttpLib`, `TSSLXmlSignLib`, `TpcnTipoAmbiente`, `TSSLType`,
`TTimeZoneModoDeteccao`, `TACBrPosPrinterModelo`, `TACBrPosPaginaCodigo`, `TACBrPosTipoCorte`,
`TACBrPosDirecao`). Se o ACBr alterar um desses tipos, os itens correspondentes no `.lfm` devem ser revisados.

### Abas

| Aba           | Conteúdo                                                                  |
|---------------|---------------------------------------------------------------------------|
| Geral         | Modelo/versão do documento, forma de emissão, CSC, bibliotecas SSL, opções gerais |
| Emitente      | Identificação (CNPJ/CPF, IE, razão social, fantasia, CRT, telefone) e endereço do emissor |
| WebServices   | UF, ambiente, protocolo SSL, timeouts, fuso horário, proxy               |
| Certificado   | Arquivo PFX, URL, senha, número de série, responsável técnico (CSRT)     |
| Arquivos      | Pastas (logs, schemas, NFe, eventos, inutilizações, downloads), arquivos de serviços/municípios, opções de separação |
| Impressora    | Configurações do `ACBrPosPrinter` (porta, página de código, barras, QR Code, logotipo, gaveta, modo página) |
| DANFE         | Componente de DANFE usado pelo `ACBrNFe1` do `frmMain`                    |

Layout: cada aba tem um `TScrollBox` com `TGroupBox` alinhados ao topo, usando `ChildSizing`
(duas colunas: rótulo e editor) para dimensionamento automático.

### Métodos privados

| Método                                  | Descrição                                          |
|-----------------------------------------|----------------------------------------------------|
| `CarregarIni` / `SalvarIni`             | Lê/grava o INI completo                            |
| `CarregarGeral` / `SalvarGeral`         | `ACBrNFe1.Configuracoes.Geral` ↔ aba Geral         |
| `CarregarWebServices` / `SalvarWebServices` | `Configuracoes.WebServices` ↔ aba WebServices  |
| `CarregarCertificado` / `SalvarCertificado` | `Configuracoes.Certificados` e `RespTec` ↔ aba Certificado |
| `CarregarArquivos` / `SalvarArquivos`   | `Configuracoes.Arquivos` ↔ aba Arquivos            |
| `CarregarPosPrinter` / `SalvarPosPrinter` | Seção `PosPrinter` do INI ↔ aba Impressora       |
| `CarregarDANFE` / `SalvarDANFE`         | Seção `DANFE` do INI ↔ aba DANFE                   |

### Métodos protegidos

| Método                                  | Descrição                                          |
|-----------------------------------------|----------------------------------------------------|
| `CarregarEmitente` / `SalvarEmitente`   | Seção `Emitente` do INI ↔ aba Emitente. São protegidos para os testes acessarem por uma subclasse, sem abrir o form em modal |

## Testes

`tests/tstfrmconfig.pas` (projeto `tests/nfestudiotests.lpi`). Usa `TfrmConfigTeste`, uma subclasse que expõe
`CarregarEmitente`/`SalvarEmitente`, e um `TMemIniFile` em memória. Confere a carga com máscaras, a gravação
sem máscara, o INI vazio (CEP, CRT e UF sem valor) e o CNPJ alfanumérico.
