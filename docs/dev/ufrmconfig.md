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
