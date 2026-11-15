# ufrmemissaonfe

Formulário de emissão de NF-e/NFC-e: edição da nota em abas, abertura e gravação de XML (inclusive rascunho, sem
emitir), validação e envio à SEFAZ. As regras ficam no [uemissaonfe](uemissaonfe.md). O form só transfere os dados
entre os controles e o `TNFe`.

## TfrmEmissaoNFe

### Uso

```pascal
TfrmEmissaoNFe.Exibir(ArquivoIni);
```

Chamado pelo botão **Emitir NF-e/NFC-e** do menu do [frmMain](ufrmmain.md). `Exibir` cria o form e chama
`Iniciar(Ini)`, que:

1. Carrega no `ACBrNFe1` do form as mesmas configurações do frmMain (`Configuracoes.LerIni`): certificado, ambiente,
   UF, modelo, paths e opções do XML.
2. Cria uma nota nova com `TEmissaoNFe.NovaNota`, que preenche o emitente pela seção `[Emitente]` do INI.
3. Mostra a nota (`CarregarTela`) e abre em modal.

### Barra de ferramentas

| Botão | Ação |
|-------|------|
| Nova nota | Confirma e descarta a nota atual, criando outra a partir da configuração |
| Abrir XML | `AbrirArquivo`: carrega rascunho, nota assinada ou autorizada (`nfeProc`) |
| Salvar XML | `SalvarArquivo`: grava o XML sem assinatura, mesmo com pendências |
| Validar | `ValidarNota`: regras próprias e do ACBr; o resultado vai para a aba Validação |
| Emitir | Valida; sem erros, confirma (modelo, número, série e ambiente) e chama `TEmissaoNFe.Emitir`; mostra chave e protocolo ou o motivo da rejeição |

O rodapé (`lblSituacao`) indica rascunho ou nota autorizada (com protocolo). Alterar uma nota autorizada exige nova
emissão.

### Abas

| Aba | Conteúdo |
|-----|----------|
| Identificação | Modelo, série, número, código numérico (0 = automático), natureza, datas, tipo, finalidade, destino, consumidor final, presença, DANFE, tipo de emissão, ambiente, município do fato gerador; contingência; intermediador; tipo de nota de crédito/débito e município do IBS (reforma tributária) |
| Emitente | Identificação, CRT e endereço; botão **Recarregar dados da configuração** (`PreencherEmitente`) |
| Destinatário | Identificação (CNPJ/CPF ou estrangeiro, indicador de IE, IE, SUFRAMA, IM, e-mail) e endereço |
| Itens | Grade de itens (`grdItens`, somente leitura), botões novo/excluir/calcular e o editor do item selecionado em abas: Produto, ICMS (com ST, crédito do Simples e desoneração), IPI, PIS/COFINS, IBS/CBS e Devolução |
| Transporte | Modalidade do frete, transportadora, veículo e volumes (`grdVolumes`) |
| Pagamento e cobrança | Pagamentos (`grdPagamentos`), fatura e duplicatas (`grdDuplicatas`) |
| Referências | Documentos referenciados (`grdReferencias`): NF-e/NFC-e, CT-e, NF modelo 1/1A, NF de produtor e cupom fiscal |
| Informações adicionais | Informações ao Fisco e complementares |
| Totais | Totais calculados (somente leitura), recalculados ao abrir a aba |
| Validação | Erros e avisos da última validação |

### Combos e grades com códigos

Os itens de combos e das colunas com lista (`PickList`) usam o formato `código - descrição` com o código oficial do
leiaute (ex.: `4 - Devolução de mercadoria`, `03 - Cartão de crédito`). A conversão usa as funções `XxxToStr` e
`StrToXxx` do ACBr, e não a ordem dos enumerados. Itens sem código (ex.: `Não informado`) valem vazio.

| Função | Descrição |
|--------|-----------|
| `CodigoDoTexto(Texto)` | Código antes de `' - '` (vazio se não houver) |
| `CodigoSelecionado(Combo)` | Código do item selecionado |
| `IndiceDoCodigo(Itens, Codigo)` | Índice do item com o código (o código vazio encontra o item sem código) |
| `SelecionarCodigo(Combo, Codigo)` | Seleciona pelo código (nenhum item se não existir) |
| `ValorDoTexto(Texto)` | Número digitado em grade: aceita vírgula (com ponto de milhar) ou ponto decimal |

Um combo sem seleção não altera o valor da nota. Assim, um valor carregado do XML que não está na lista (ex.: CST de
partilha) é mantido.

Nas grades, linhas totalmente vazias são ignoradas e as datas usam `dd/mm/aaaa`. Na de pagamentos, os dados de cartão
(CNPJ, bandeira e autorização) só são gravados com o tipo de integração informado. Na de referências, uma linha sem
tipo é tratada como NF-e/NFC-e.

### Reações na tela

| Controle | Reação |
|----------|--------|
| Modelo (`cbxIdeModeloChange`) | `AplicarRegrasModelo` e recarrega a tela |
| Finalidade (`cbxIdeFinNFeChange`) | `AplicarRegrasFinalidade`; em complementar e devolução abre a aba Referências |
| UF do destinatário (`cbxDestUFChange`) | `DefinirDestinoOperacao` |
| CRT (`cbxEmitCRTChange`) | Alterna CST/CSOSN e campos do crédito do Simples |
| Tipo de emissão, intermediador e indicador de IE (`cbxAjustarTelaChange`) | Habilita contingência, dados do intermediador e IE do destinatário |

`AjustarTela` também esconde, na NFC-e, a aba Referências e a aba IPI do item, e desabilita fatura, duplicatas, IE e
SUFRAMA do destinatário e IE-ST do emitente. A aba Devolução do item só aparece na finalidade 4. O editor de item só
fica habilitado quando há itens.

### Fluxo de dados

- `CarregarTela`: `TNFe` → controles (`Carregar*`). Durante a carga `FCarregando` impede que eventos `OnChange`
  releiam a tela.
- `LerTela`: controles → `TNFe` (`Ler*`). Grava antes o item em edição e atualiza `Ide.cUF` pela UF do emitente.
- Os grupos de campos simples são gravados no próprio `TNFe`, então informações carregadas do XML sem campo na tela
  (ex.: retirada, entrega, autXML, combustível) são preservadas. As coleções das grades (pagamentos, volumes,
  duplicatas e referências) são refeitas a partir das grades, e campos sem coluna (ex.: lacres) se perdem.
- Item: `SelecionarItem` grava o item em edição quando o índice muda e carrega o novo. A troca de linha na grade faz o
  mesmo (`OnBeforeSelection`/`OnSelection`). `CarregarTela` reseleciona o item sem regravar o editor, pois a nota
  pode ter sido alterada pelas regras.
- **Calcular impostos do item** chama `TEmissaoNFe.CalcularItem`; **Novo item** chama `NovoItem` (padrões
  conforme tipo, destino e regime); **Excluir item** confirma e chama `ExcluirItem` (renumera).

### Métodos públicos

| Método | Descrição |
|--------|-----------|
| `Iniciar(Ini)` | Configuração do ACBr, nota nova e carga da tela |
| `CarregarTela` / `LerTela` | Nota ↔ controles |
| `SelecionarItem(Index)` / `ExcluirItem(Index)` | Seleção e exclusão de item |
| `AbrirArquivo(Arquivo)` / `SalvarArquivo(Arquivo)` | XML sem diálogos (usados pelos botões) |
| `ValidarNota` | Valida e preenche a aba Validação (que é ativada se houver erros ou avisos) |
| `Emissao` | O `TEmissaoNFe` do form |

### Fora do escopo do form

Grupos sem campos na tela, preservados quando vêm do XML: retirada/entrega, autorização de download (autXML),
exportação, compra, cana, responsável técnico, veículos novos, medicamentos, armas, combustíveis, rastreabilidade, II,
DIFAL (ICMSUFDest), ISSQN, PIS-ST/COFINS-ST, Imposto Seletivo e os grupos de diferimento/redução/crédito presumido do
IBS/CBS. A correção de nota autorizada por Carta de Correção (CC-e) é um evento e não faz parte deste form.

## Testes

`tests/tstfrmemissaonfe.pas` (projeto `tests/nfestudiotests.lpi`). Cria o form com um INI em memória e cobre: funções
de código e de valor, emitente na abertura, troca para NFC-e e de volta, devolução (pagamento 90 e aba de referências),
itens (novo, cálculo, troca de linha, exclusão e renumeração), CST/CSOSN conforme o regime, grades ↔ nota
(referência, duplicata, volume e cartão), XML salvo e reaberto pela tela, validação de nota incompleta e destino da
operação pela UF.

O `.lfm` e as declarações dos campos simples foram gerados a partir de uma especificação. Ao incluir um campo, siga o
padrão de um grupo existente: par `lbl`/controle no `TGroupBox` com `ChildSizing` de 4 controles por linha, mais a
linha correspondente em `Carregar*` e `Ler*`.
