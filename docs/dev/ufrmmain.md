# ufrmmain

Formulário principal da aplicação. Hospeda a conexão com o banco, o `TACBrNFe`, os componentes de DANFE
e o `TACBrPosPrinter`.

## TfrmMain

### Inicialização (`FormCreate`)

1. `CarregarConfiguracoes` — carrega o arquivo INI (criando-o na primeira execução) e cria as pastas da NFe.
2. `InicializarBanco` — conecta `ZConnection1` e chama `dmdNFe.CriarTabelas`.

O `dmdNFe` é criado antes do `frmMain` em `nfestudio.lpr`, pois é usado no `FormCreate`.

### Arquivo de configuração

Local: `GetAppConfigDir(False)` + `<nome do executável>.ini`

| Plataforma | Caminho típico                                   |
|------------|--------------------------------------------------|
| Linux      | `~/.config/nfestudio/nfestudio.ini`              |
| Windows    | `%LOCALAPPDATA%\nfestudio\nfestudio.ini`         |

Se o arquivo não existir, ele é criado com os paths padrão e os valores atuais (design-time) dos componentes.

| Seção        | Conteúdo                                                                 |
|--------------|--------------------------------------------------------------------------|
| `DFe`, `NFe`, `Proxy` | Configurações do `ACBrNFe1`, lidas/gravadas por `Configuracoes.LerIni`/`GravarIni` do ACBr |
| `PosPrinter` | Configurações do `ACBrPosPrinter1` (enums gravados como inteiro)          |
| `DANFE`      | Chave `Componente`: componente de DANFE atribuído ao `ACBrNFe1`           |

Valores aceitos em `[DANFE] Componente` (valor inválido usa `RL`):

| Valor      | Componente                 |
|------------|----------------------------|
| `RL`       | `ACBrNFeDANFeRL1` (padrão) |
| `ESCPOS`   | `ACBrNFeDANFeESCPOS1`      |
| `FORTES`   | `ACBrNFeDANFCeFortes1`     |
| `FORTESA4` | `ACBrNFeDANFCeFortesA4_1`  |

### Paths padrão da NFe

Base: pasta de documentos do usuário + `NFeStudio`.

- Windows: `GetWindowsSpecialDir(CSIDL_PERSONAL)` (ex.: `C:\Users\<usuario>\Documents\NFeStudio`).
- Linux: `XDG_DOCUMENTS_DIR` de `~/.config/user-dirs.dirs` (ex.: `~/Documentos/NFeStudio`);
  na ausência, `~/Documents/NFeStudio`.

| Propriedade ACBr                      | Subpasta         |
|---------------------------------------|------------------|
| `Arquivos.PathSalvar`                 | `Logs`           |
| `Arquivos.PathNFe`                    | `NFe`            |
| `Arquivos.PathEvento`                 | `Eventos`        |
| `Arquivos.PathInu`                    | `Inutilizacoes`  |
| `Arquivos.DownloadDFe.PathDownload`   | `Downloads`      |

`Arquivos.PathSchemas` aponta para `Schemas` ao lado do executável; no Linux, se existir,
usa `<prefixo>/share/nfestudio/Schemas` (instalação por pacote em `/usr/bin`).

As pastas acima são criadas (`ForceDirectories`) a cada inicialização, com os valores lidos do INI.

### Métodos privados

| Método                    | Descrição                                                         |
|---------------------------|-------------------------------------------------------------------|
| `ArquivoIni`              | Caminho completo do INI                                           |
| `PastaDocumentos`         | Pasta de documentos do usuário, conforme a plataforma             |
| `PastaSchemas`            | Pasta dos schemas XSD da NFe                                      |
| `DefinirPathsPadraoNFe`   | Atribui os paths padrão ao `ACBrNFe1`                             |
| `CriarPastasNFe`          | Cria as pastas configuradas no `ACBrNFe1`                         |
| `GravarConfigPosPrinter`  | Grava as configurações do `ACBrPosPrinter1` no INI                |
| `LerConfigPosPrinter`     | Lê as configurações do `ACBrPosPrinter1` do INI                   |
| `SelecionarDANFE`         | Atribui o componente de DANFE ao `ACBrNFe1`                       |
| `CriarArquivoIni`         | Grava o INI inicial com paths e configurações padrão              |
| `CarregarConfiguracoes`   | Cria (se necessário) e lê o INI                                   |
| `InicializarBanco`        | Conecta ao banco e cria as tabelas                                |
