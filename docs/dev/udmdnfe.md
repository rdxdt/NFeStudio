# udmdnfe

Datamodule com as queries de persistência das notas fiscais (banco SQLite via Zeos, conexão `frmMain.ZConnection1`).

## TdmdNFe

| Componente        | Tipo     | Finalidade                                   |
|-------------------|----------|----------------------------------------------|
| `qryNFeCab`       | TZQuery  | Cabeçalho da nota (`NFE_CAB`)                |
| `qryNFeDet`       | TZQuery  | Itens da nota (`NFE_DET`)                    |
| `qryNFeFat`       | TZQuery  | Fatura (`NFE_FAT`)                           |
| `qryNFeDup`       | TZQuery  | Duplicatas (`NFE_DUP`)                       |
| `qryNFeVol`       | TZQuery  | Volumes transportados (`NFE_VOL`)            |
| `qryNFePgt`       | TZQuery  | Formas de pagamento (`NFE_PAG`)              |
| `cmdCreateTables` | TZQuery  | DDL de criação das tabelas e índices         |

### cmdCreateTables

Contém o DDL derivado das classes de `TACBrNFe.NotasFiscais[i].NFe` (`ACBrNFe.Classes.pas`).
Todos os comandos usam `IF NOT EXISTS`, podendo ser executados a cada abertura do banco.

**Atenção:** o SQL possui vários comandos separados por `;`. O `TZQuery.ExecSQL` do Zeos executa
somente o primeiro comando do texto no SQLite; use `CriarTabelas` em vez de `cmdCreateTables.ExecSQL`.

### CriarTabelas

```pascal
procedure CriarTabelas;
```

Cria as tabelas e índices da NFe executando, um a um, os comandos de `cmdCreateTables.SQL`
(separados pelo `TZSQLStrings.Statements`) via `Connection.ExecuteDirect`.
Pode ser chamado a cada abertura do banco, pois todos os comandos usam `IF NOT EXISTS`.
Exceções do banco são propagadas ao chamador.

O `ON DELETE CASCADE` das chaves estrangeiras só tem efeito com `PRAGMA foreign_keys = ON` na conexão.

## Modelo de dados

A chave de todas as tabelas é `CHNFE` (chave de acesso com 44 dígitos, `infNFe.ID` sem o prefixo `NFe`).

| Tabela    | Origem no ACBr                         | Chave primária   | Cardinalidade |
|-----------|----------------------------------------|------------------|---------------|
| `NFE_CAB` | `TNFe` (grupos 1:1 achatados)          | `CHNFE`          | 1             |
| `NFE_DET` | `TNFe.Det[]` (`Prod` + `Imposto`)      | `CHNFE, NITEM`   | 1:N           |
| `NFE_FAT` | `TNFe.Cobr.Fat`                        | `CHNFE`          | 1:1           |
| `NFE_DUP` | `TNFe.Cobr.Dup[]`                      | `CHNFE, SEQ`     | 1:N           |
| `NFE_VOL` | `TNFe.Transp.Vol[]`                    | `CHNFE, SEQ`     | 1:N           |
| `NFE_PAG` | `TNFe.pag[]`                           | `CHNFE, SEQ`     | 1:N           |

`SEQ` é a posição do item na coleção do ACBr (iniciando em 1).

### Convenções

- Nomes das colunas seguem as tags do XML, prefixadas pelo grupo de origem
  (ex.: `EMIT_XNOME`, `TOT_VNF`, `ICMS_VBC`, `IBSUF_VIBSUF`).
- Enumerados do ACBr (`Tpcn*`, `TCST*`, etc.) são gravados como `VARCHAR` com o código do XML
  (ex.: `ICMS_CST = '00'`, `TPAG = '01'`), usando as funções `*ToStr` do ACBr.
- Valores monetários: `NUMERIC(15,2)`; percentuais: `NUMERIC(7,4)`; quantidades: `NUMERIC(15,4)`;
  valores unitários: `NUMERIC(21,10)`.

### NFE_CAB — grupos achatados

`infNFe`, `Ide` (+ `gCompraGov`), `Emit` (+ `EnderEmit`), `Avulsa`, `Dest` (+ `EnderDest`), `Retirada`,
`Entrega`, `Total` (`ICMSTot`, `ISSQNtot`, `retTrib`, `ISTot`, `IBSCBSTot`, `vNFTot`),
`Transp` (`modFrete`, `Transporta`, `retTransp`, `veicTransp`, `vagao`, `balsa`), `pag.vTroco`,
`infIntermed`, `InfAdic` (`infAdFisco`, `infCpl`), `exporta`, `compra`, `cana` (totais),
`agropecuario.guiaTransito`, `infNFeSupl`, `infRespTec` e `procNFe` (protocolo de autorização, prefixo `PROT_`).

### NFE_DET — grupos achatados

`Prod`, `veicProd` (`VEIC_`), `comb` (`COMB_`, `CIDE_`, `ENCERRANTE_`), `Imposto.vTotTrib`, `ICMS`, `IPI`, `II`,
`PIS`, `PISST`, `COFINS`, `COFINSST`, `ISSQN`, `ICMSUFDest`, `ISel` (`IS_`), `IBSCBS` (`IBSCBS_`, `IBSUF_`,
`IBSMUN_`, `CBS_`, `TRIBREG_`, `IBSCREDPRES_`, `CBSCREDPRES_`, `TRIBCOMPRAGOV_`, `MONO_`, `TRANSFCRED_`,
`CREDPRESIBSZFM_`), `pDevol`, `vIPIDevol`, `infAdProd`, `obsCont`, `obsFisco`, `vItem` e `DFeReferenciado`.

### Coleções não persistidas

As coleções abaixo não possuem tabela própria neste DDL:
`Ide.NFref`, `Ide.gPagAntecipado`, `autXML`, `Prod.NVE`, `Prod.DI` (+ `adi`), `Prod.detExport`, `Prod.rastro`,
`Prod.med`, `Prod.arma`, `Prod.CredPresumido`, `comb.origComb`, `Vol.Lacres`, `Transp.Reboque`,
`InfAdic.obsCont`, `InfAdic.obsFisco`, `InfAdic.procRef`, `cana.fordia`, `cana.deduc` e `agropecuario.defensivo`.
