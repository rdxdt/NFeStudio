# ureltotalsintetico

Relatório Fortes Report com os totais por dia das notas do filtro atual do grid, seguido da soma de todos
os dias.

## TrelTotaisSintetico

```pascal
TrelTotaisSintetico = class(TForm)
```

Form `relTotaisSintetico`, que contém apenas o `TRLReport` (`rlrTotaisSintetico`). A página é A4 paisagem, por
causa das 13 colunas. Os dados vêm de `dmdNFe.qryTotaisSintetico` (ver [udmdnfe](udmdnfe.md)), via
`dmdNFe.dtsTotaisSintetico`.

### Exibir

```pascal
class procedure Exibir;
```

1. Sem filtro aplicado (`dmdNFe.qryNFeCab` fechada), avisa e sai.
2. Chama `dmdNFe.AbrirTotaisSintetico`. Sem notas no período, avisa e sai.
3. Cria o form, mostra o preview do Fortes (`rlrTotaisSintetico.Preview`) e o libera ao fechar.
4. Fecha `qryTotaisSintetico` ao final.

Chamado pelo botão `btnTotaisSintetico` do [frmRelatorios](ufrmrelatorios.md).

### Bandas

| Banda          | Tipo             | Conteúdo                                                        |
|----------------|------------------|-----------------------------------------------------------------|
| `rlbCabecalho` | `btHeader`       | Título, período (`rllPeriodo`), data/hora de emissão e página   |
| `rlbTitulos`   | `btColumnHeader` | Títulos das colunas                                             |
| `rlbDetalhe`   | `btDetail`       | Um `TRLDBText` (`rdt<Coluna>`) por coluna, uma linha por dia    |
| `rlbTotal`     | `btSummary`      | `TRLDBResult` (`rdr<Coluna>`, `Info = riSum`): soma de todos os dias |

O período é preenchido no `FormCreate` a partir dos parâmetros de `qryTotaisSintetico`. Por isso a query deve
ser aberta antes de criar o form.

### Colunas

| Coluna        | Campo          | Máscara       |
|---------------|----------------|---------------|
| Dia           | `DIA`          | —             |
| Qtd. Vendas   | `QTD_VENDAS`   | `#,##0`       |
| Total Vendas  | `TOT_VNF`      | `#,##0.00`    |
| Qtd. Produtos | `QTD_PRODUTOS` | `#,##0.####`  |
| ICMS, PIS, COFINS, IPI, II | `TOT_VICMS`, `TOT_VPIS`, `TOT_VCOFINS`, `TOT_VIPI`, `TOT_VII` | `#,##0.00` |
| IS            | `TOT_VIS`      | `#,##0.00`    |
| CBS           | `TOT_VCBS`     | `#,##0.00`    |
| IBS Municipal | `TOT_VIBSMUN`  | `#,##0.00`    |
| IBS Estadual  | `TOT_VIBSUF`   | `#,##0.00`    |

`rdrQtdVendasCompute` (`OnCompute` de `rdrQtdVendas`) converte o valor para `Integer`. O `COUNT(*)` chega do
Zeos como `Int64`, e o `TRLDBResult` só acumula `varSmallint`, `varInteger`, `varSingle`, `varDouble` e
`varCurrency`. Sem a conversão, o total de vendas ficaria vazio.

Ao alterar apenas o `.lfm`, o `lazbuild` não recompila a unit. É preciso alterar o `.pas` ou usar `-B`.

## Testes

`tests/tstreltotalsintetico.pas` (projeto `tests/nfestudiotests.lpi`). Grava notas em três dias, filtra dois,
cria o form, chama `rlrTotaisSintetico.Prepare` (sem preview) e confere o período e as somas da banda
`rlbTotal`.
