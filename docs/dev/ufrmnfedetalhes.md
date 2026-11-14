# ufrmnfedetalhes

Form somente leitura que exibe, organizados por categoria, todos os dados da NFe selecionada em
`dmdNFe.qryNFeCab` (ver [udmdnfe](udmdnfe.md)).

## TfrmNFeDetalhes

### Uso

```pascal
TfrmNFeDetalhes.Exibir(@ImprimirDANFE);   // AoImprimirDANFE é opcional
```

`Exibir` não faz nada se `qryNFeCab` estiver fechada ou vazia. Caso contrário, cria o form, atribui
`OnImprimirDANFE`, exibe em modal e o libera. No `frmMain` é chamado pelo duplo clique no `DBGrid1`,
passando `TfrmMain.ImprimirDANFE`.

### Impressão da DANFE (`tbrAcoes`)

```pascal
TImprimirDANFEEvent = procedure(const Chave: string) of object;
property OnImprimirDANFE: TImprimirDANFEEvent;
```

O botão `tbtImprimir` chama `OnImprimirDANFE` com a `CHNFE` da nota exibida e mostra em mensagem qualquer
exceção. O form não conhece o `ACBrNFe1`: a impressão fica com quem o abriu, o que mantém a unit livre dos
pacotes de DANFE (e utilizável no projeto de testes). Sem `OnImprimirDANFE` o botão fica desabilitado.

### Fontes de dados

| DataSource          | Query               | Uso                                              |
|---------------------|---------------------|--------------------------------------------------|
| `dmdNFe.dtsNFeCab`  | `qryNFeCab`         | Todos os campos do cabeçalho                     |
| `dtsNFeDet`         | `dmdNFe.qryNFeDet`  | Grade de itens e detalhes do item selecionado    |
| `dtsNFeFat`         | `dmdNFe.qryNFeFat`  | Fatura                                           |
| `dtsNFeDup`         | `dmdNFe.qryNFeDup`  | Grade de duplicatas                              |
| `dtsNFeVol`         | `dmdNFe.qryNFeVol`  | Grade de volumes                                 |
| `dtsNFePgt`         | `dmdNFe.qryNFePgt`  | Grade de formas de pagamento                     |

As queries de detalhe são mestre-detalhe de `dtsNFeCab` (parâmetro `:CHNFE`). `FormCreate` abre as que
estiverem fechadas e `FormDestroy` fecha somente as que ele abriu: abertas, seriam reabertas a cada
movimentação do grid principal.

### Organização

- `tbrAcoes` (topo): botão **Imprimir DANFE**.
- `pnlResumo`: chave, número, série, modelo, emissão, emitente, destinatário e valor total.
- `pgcNFe`: uma aba por categoria. Cada aba tem um `TScrollBox` (`sbx<Aba>`) com `TGroupBox` (`grp<Grupo>`)
  empilhados (`Align = alTop`, `AutoSize = True`). Os grupos usam o mesmo `ChildSizing` em grade do painel
  de detalhes do `frmMain` (pares `lbl`/`edt`, largura dos edits fixada por `Width` + `Constraints.MinWidth`).

| Aba                  | Grupos                                                                              |
|----------------------|-------------------------------------------------------------------------------------|
| Identificação        | Identificação (`IDE_*`, `VERSAO`), Contingência, Intermediador, Compra Governamental, Nota Avulsa |
| Emitente             | Emitente, Endereço (`EMIT_*`)                                                       |
| Destinatário         | Destinatário, Endereço (`DEST_*`)                                                   |
| Retirada / Entrega   | `RETIRADA_*`, `ENTREGA_*`                                                           |
| Produtos             | `grdItens` + `pgcItem` com os dados do item selecionado (ver abaixo)               |
| Totais               | ICMS e Valores (`TOT_*`), ISSQN, Retenções, IS/IBS/CBS, IBS/CBS Monofásico          |
| Transporte           | Transporte, Transportadora, Veículo, Retenção ICMS, `grdVolumes`                    |
| Cobrança             | Fatura (`qryNFeFat`), `grdDuplicatas`, `grdPagamentos` (`qryNFePgt`), Troco (`PAG_VTROCO`) |
| Inf. Adicionais      | Informações complementares e do fisco (`TDBMemo`), Exportação, Compra, Cana, Agro   |
| Protocolo            | Protocolo, Retorno, Responsável Técnico, Suplementar (NFC-e), QR Code (`TDBMemo`)   |

Abas do item (`pgcItem`), separadas de `grdItens` por `splItens`:

| Aba                    | Grupos                                                                            |
|------------------------|-----------------------------------------------------------------------------------|
| Produto                | Produto, Comercial/Tributável, Valores, Observações, Informações Adicionais (`TDBMemo`) |
| ICMS                   | ICMS, ICMS ST, FCP, ICMS Monofásico, ICMS UF Destino                              |
| IPI / II               | IPI, Imposto de Importação                                                        |
| PIS / COFINS           | PIS, PIS ST, COFINS, COFINS ST                                                    |
| ISSQN                  | ISSQN                                                                             |
| IS / IBS / CBS         | Imposto Seletivo, IBS/CBS, IBS UF, IBS Municipal, CBS, Tributação Regular, Crédito Presumido, Compra Governamental, Monofásico, Transferência de Crédito/ZFM |
| Veículo / Combustível  | Veículo Novo, Combustível, CIDE, Encerrante                                       |

Todos os campos persistentes de `qryNFeCab`, `qryNFeDet` (exceto `CHNFE`) e `qryNFeFat` (exceto `CHNFE`)
aparecem em algum grupo. Códigos de enumerados (ex.: `IDE_TPNF`, `ICMS_CST`) são exibidos como gravados no XML.

### Nomes dos componentes

`lbl`/`edt` + origem + nome do campo em Pascal case, por partes separadas por `_`:

| Origem       | Prefixo   | Exemplo (campo → edit)                    |
|--------------|-----------|-------------------------------------------|
| Resumo       | `Resumo`  | `CHNFE` → `edtResumoChnfe`                |
| Cabeçalho    | (nenhum)  | `EMIT_XNOME` → `edtEmitXnome`             |
| Item         | `Item`    | `ICMS_VBC` → `edtItemIcmsVbc`             |
| Fatura       | `Fat`     | `NFAT` → `edtFatNfat`                     |

Memos usam `mmo` (ex.: `mmoInfadicInfcpl`).

## Testes

`tests/tstfrmnfedetalhes.pas`: importa o XML de exemplo em um banco temporário, cria o form (sem exibir) e
verifica o carregamento do `.lfm`, os valores exibidos de cabeçalho, item, fatura e memo, que o form fecha
somente as queries de detalhe que abriu e que o botão de impressão envia a chave da nota (desabilitado sem
`OnImprimirDANFE`). Por criar um form, este teste precisa de um display disponível.
