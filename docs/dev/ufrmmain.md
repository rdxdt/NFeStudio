# ufrmmain

Formulário principal da aplicação. Hospeda a conexão com o banco, o `TACBrNFe`, os componentes de DANFE
e o `TACBrPosPrinter`.

## TfrmMain

### Inicialização (`FormCreate`)

1. `CarregarConfiguracoes` — carrega o arquivo INI (criando-o na primeira execução) e cria as pastas da NFe.
2. `InicializarBanco` — conecta `ZConnection1` e chama `dmdNFe.CriarTabelas`.

O `dmdNFe` é criado antes do `frmMain` em `nfestudio.lpr`, pois é usado no `FormCreate`.

### Listagem de notas (`DBGrid1`)

Ligado a `dmdNFe.dtsNFeCab` (`dmdNFe.qryNFeCab`). Colunas:

| Campo          | Título          | Largura                     |
|----------------|-----------------|-----------------------------|
| `CHNFE`        | Chave de Acesso | 340                         |
| `IDE_DHEMI`    | Emissão         | 140                         |
| `DEST_CNPJCPF` | CNPJ/CPF Dest.  | 130                         |
| `DEST_XNOME`   | Destinatário    | ocupa o espaço restante     |
| `TOT_VNF`      | Valor Total     | 120                         |

`AutoFillColumns = True` com `SizePriority = 1` somente em `DEST_XNOME`; as demais colunas mantêm a
largura definida.

### Importação de XML (`btnImportarXMLClick`)

Seleciona o diretório em `dlgSelDir` e chama `ProcessadorNFe.Importar`. O `ProcessadorNFe` é criado no
`FormCreate` com `ExibirProgresso = True`, então ele próprio exibe o `TfrmAguarde` com o progresso
(ver [uprocessadornfe](uprocessadornfe.md)) e o libera antes de qualquer mensagem de erro.

Ao final, mesmo após erro (parte das notas pode ter sido gravada), `AjustarPeriodoFiltro` consulta a menor e a
maior data de emissão de `NFE_CAB` (`dmdNFe.ObterPeriodoNFeCab`), atribui a `dtpInicial`/`dtpFinal` e aplica o
filtro, deixando visíveis todas as notas do banco, inclusive as recém-importadas. Com a tabela vazia, nada muda.

### Detalhes da NFe (`DBGrid1DblClick`)

O duplo clique no grid abre o `TfrmNFeDetalhes` com a nota selecionada (ver [ufrmnfedetalhes](ufrmnfedetalhes.md)),
passando `ImprimirDANFE` para o botão de impressão.

### Impressão da DANFE (`ImprimirDANFE`)

```pascal
procedure ImprimirDANFE(const Chave: string);
```

1. Chama `ProcessadorNFe.AtualizarProtocolo` (ver [uprocessadornfe](uprocessadornfe.md)): se a nota gravada
   não tiver protocolo, consulta a SEFAZ e, havendo autorização, regrava a nota com o `nfeProc`. Se a consulta
   falhar (certificado, comunicação), exibe um aviso e segue a impressão sem protocolo.
   Os campos `PROT_*` já exibidos no grid/detalhes só refletem a atualização quando a consulta for reaberta.
2. Lê o XML gravado em `NFE_CAB.XML` (`dmdNFe.ObterXMLNFe`); sem XML gera exceção pedindo a reimportação.
3. Carrega a nota em `ACBrNFe1.NotasFiscais` e pergunta o modelo de impressão com
   `TfrmImprimirDANFE.Selecionar` (ver [ufrmimprimirdanfe](ufrmimprimirdanfe.md)).
4. O padrão vem de `TipoDANFEPadrao`, derivado do `ACBrNFe1.DANFE` atual, que `SelecionarDANFE` define a partir
   de `[DANFE] Componente` (`ESCPOS` → POS, `FORTES` → bobina, `RL`/`FORTESA4` → A4).
5. `ComponenteDANFE` converte a escolha no componente; em A4, NFC-e usa `ACBrNFeDANFCeFortesA4_1` e NF-e
   `ACBrNFeDANFeRL1`.
6. Atribui o componente a `ACBrNFe1.DANFE` somente durante a impressão, restaurando o configurado ao final,
   e limpa `NotasFiscais`.

`ACBrNFeDANFeESCPOS1.PosPrinter` aponta para `ACBrPosPrinter1`.

### Relatórios (`btnRelatoriosClick`)

Esconde o `pnlMenu` e abre o form de opções de relatório com `TfrmRelatorios.Exibir`
(ver [ufrmrelatorios](ufrmrelatorios.md)).

### Filtro por período (`btnFiltrarClick`)

Chama `dmdNFe.FiltrarNFeCab(dtpInicial.Date, dtpFinal.Date)`. A hora dos pickers é ignorada: são listadas as
notas emitidas do início do dia inicial até o fim do dia final (ver [udmdnfe](udmdnfe.md)).

### Configurações (`btnConfigClick`)

Abre o `TfrmConfig` via `TfrmConfig.Executar(ArquivoIni)` (ver [ufrmconfig](ufrmconfig.md)); se o usuário
salvar, chama `CarregarConfiguracoes` para aplicar o INI gravado.

### Painel de detalhes (`pnlDetalhes`)

Painel alinhado ao rodapé com o `pgcDetalhes`. Todos os campos são `TDBEdit` somente leitura ligados a
`dmdNFe.dtsNFeCab` (o mesmo DataSource do grid), acompanhando o registro selecionado.

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
| `AjustarPeriodoFiltro`    | Ajusta os pickers à menor/maior emissão em `NFE_CAB` e filtra     |
| `TipoDANFEPadrao`         | Opção de impressão correspondente à DANFE configurada             |
| `ComponenteDANFE`         | Componente de DANFE para a opção escolhida e o modelo da nota     |
