# ufrmmain

Formulário principal da aplicação. Hospeda a conexão com o banco, o `TACBrNFe`, os componentes de DANFE
e o `TACBrPosPrinter`.

## TfrmMain

### Inicialização (`FormCreate`)

1. `CarregarConfiguracoes` — carrega o arquivo INI (criando-o na primeira execução) e cria as pastas da NFe.
2. `InicializarBanco` — conecta `ZConnection1` e chama `dmdNFe.CriarTabelas`.

O `dmdNFe` é criado antes do `frmMain` em `nfestudio.lpr`, pois é usado no `FormCreate`.

### Listagem de notas (`DBGrid1`)

Ligado a `dsNFeCab` (`dmdNFe.qryNFeCab`). Colunas:

| Campo          | Título          | Largura                     |
|----------------|-----------------|-----------------------------|
| `CHNFE`        | Chave de Acesso | 340                         |
| `IDE_DHEMI`    | Emissão         | 140                         |
| `DEST_CNPJCPF` | CNPJ/CPF Dest.  | 130                         |
| `DEST_XNOME`   | Destinatário    | ocupa o espaço restante     |
| `TOT_VNF`      | Valor Total     | 120                         |

`AutoFillColumns = True` com `SizePriority = 1` somente em `DEST_XNOME`; as demais colunas mantêm a
largura definida.

### Painel de detalhes (`pnlDetalhes`)

Painel alinhado ao rodapé com o `pgcDetalhes`. Todos os campos são `TDBEdit` somente leitura ligados a
`dsNFeCab`, acompanhando o registro selecionado no grid.

| Aba                  | Conteúdo                                                     |
|----------------------|--------------------------------------------------------------|
| `tabDestinatario`    | Campos `DEST_*` (identificação, endereço e contato)          |
| `tabTotaisICMS`      | Campos `TOT_*` do `ICMSTot`                                  |
| `tabTotaisISSQN`     | Campos `ISSQNTOT_*`                                          |
| `tabRetencoes`       | Campos `RETTRIB_*`                                           |
| `tabTotaisIBSCBS`    | `ISTOT_VIS`, `IBSCBSTOT_*`, `IBSUFTOT_*`, `IBSMUNTOT_*`, `IBSTOT_*`, `CBSTOT_*`, `MONOTOT_*` e `TOT_VNFTOT` |

Cada aba contém um `TScrollBox` (`sbx<Aba>`) com `ChildSizing.Layout = cclLeftToRightThenTopToBottom`,
que distribui os pares `lbl<Campo>`/`edt<Campo>` em grade (3 pares por linha no destinatário, 4 nos totais).
Para incluir um campo basta adicionar o par label/edit na posição desejada da lista de controles da aba.
A largura dos edits é fixada por `Width` + `Constraints.MinWidth`, pois o ChildSizing redistribuiria o
espaço livre também para os labels.

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
