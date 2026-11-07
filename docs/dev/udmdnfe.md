# udmdnfe

Datamodule com as queries de persistência das notas fiscais (banco SQLite via Zeos, conexão `frmMain.ZConnection1`).

## TdmdNFe

| Componente        | Tipo           | Finalidade                                   |
|-------------------|----------------|----------------------------------------------|
| `qryNFeCab`       | TZQuery        | Cabeçalho da nota (`NFE_CAB`) — mestre       |
| `dtsNFeCab`       | TDataSource    | Liga `qryNFeCab` às queries de detalhe       |
| `qryNFeDet`       | TZQuery        | Itens da nota (`NFE_DET`) — detalhe          |
| `qryNFeFat`       | TZQuery        | Fatura (`NFE_FAT`) — detalhe                 |
| `qryNFeDup`       | TZQuery        | Duplicatas (`NFE_DUP`) — detalhe             |
| `qryNFeVol`       | TZQuery        | Volumes transportados (`NFE_VOL`) — detalhe  |
| `qryNFePgt`       | TZQuery        | Formas de pagamento (`NFE_PAG`) — detalhe    |
| `sqlCreateTables` | TZSQLProcessor | DDL de criação das tabelas e índices         |

### qryNFeCab

Seleciona as notas de `NFE_CAB` cuja data de emissão (`IDE_DHEMI`) está no período informado,
ordenadas por emissão, série e número.

| Parâmetro      | Tipo   | Descrição                                  |
|----------------|--------|--------------------------------------------|
| `DATA_INICIAL` | ftDate | Primeiro dia do período (inclusivo)        |
| `DATA_FINAL`   | ftDate | Último dia do período (inclusivo)          |

O filtro usa `IDE_DHEMI < DATE(:DATA_FINAL, '+1 day')` para incluir as notas emitidas em qualquer
horário do último dia, mantendo o uso do índice `IDX_NFE_CAB_DHEMI`.

```pascal
dmdNFe.qryNFeCab.Close;
dmdNFe.qryNFeCab.ParamByName('DATA_INICIAL').AsDate := dtpInicial.Date;
dmdNFe.qryNFeCab.ParamByName('DATA_FINAL').AsDate := dtpFinal.Date;
dmdNFe.qryNFeCab.Open;
```

### Mestre-detalhe

As queries `qryNFeDet`, `qryNFeFat`, `qryNFeDup`, `qryNFeVol` e `qryNFePgt` possuem
`DataSource = dtsNFeCab` e o parâmetro `:CHNFE`. O Zeos preenche o parâmetro com o campo de mesmo
nome de `qryNFeCab` e reabre o detalhe a cada movimentação do cursor do mestre.
As queries de detalhe devem ser abertas após `qryNFeCab` e fechadas junto com ela.

### Campos persistentes

Todas as queries possuem campos persistentes (`<query><COLUNA>`, ex.: `qryNFeCabTOT_VNF`) com as classes
de campo do Zeos 8, as mesmas que o Fields Editor gera para o SQLite:

| Tipo no DDL              | Classe do campo     |
|--------------------------|---------------------|
| `VARCHAR(n)`             | `TZRawStringField`  |
| `INTEGER`                | `TZInt64Field`      |
| `NUMERIC(p,s)`           | `TZDoubleField`     |
| `DATETIME`               | `TZDateTimeField`   |
| `DATE`                   | `TZDateField`       |
| `TIME`                   | `TZTimeField`       |

Formatação de exibição:

| Colunas                                        | `DisplayFormat`             | `EditFormat`     |
|------------------------------------------------|-----------------------------|------------------|
| `NUMERIC(15,2)` (valores monetários)           | `"R$ "#,##0.00`             | `0.00`           |
| `VUNCOM`, `VUNTRIB` (`NUMERIC(21,10)`)         | `"R$ "#,##0.00########`     | `0.00########`   |
| `NUMERIC(7,4)` (percentuais)                   | `0.00##" %"`                | `0.00##`         |
| `NUMERIC(15,4)`, `NUMERIC(16,4)` (quantidades) | `#,##0.00##`                | `0.00##`         |
| `NUMERIC(15,3)` (pesos, encerrantes)           | `#,##0.00#`                 | `0.00#`          |
| `NUMERIC(21,10)` (demais)                      | `#,##0.00########`          | `0.00########`   |
| `VERSAO`                                       | `0.00`                      |                  |
| `DATETIME`                                     | `dd/mm/yyyy hh:nn:ss`       |                  |
| `DATE`                                         | `dd/mm/yyyy`                |                  |
| `TIME`                                         | `hh:nn:ss`                  |                  |

Campos decimais exibem sempre ao menos duas casas, e as casas extras só aparecem quando há valor nelas.

**Atenção:**
- O `TZDoubleField` usa o `DisplayFormat` também na edição quando o `EditFormat` está vazio. Por isso todo
  campo com `R$` ou `%` define `EditFormat` sem prefixo/sufixo; caso contrário o texto editado não seria
  convertido de volta para número.
- Nos campos de data/hora do Zeos o `DisplayFormat` é um objeto; o formato fica em `DisplayFormat.Format`.
- Separadores decimal, de milhar e de data vêm de `DefaultFormatSettings`, preenchido a partir das
  configurações regionais do sistema (no Linux, pela unit `clocale` no `uses` do `nfestudio.lpr`).
  `R$ 1.234,50` e `07/11/2026` só são exibidos com o sistema em pt-BR.

### sqlCreateTables

Contém o DDL derivado das classes de `TACBrNFe.NotasFiscais[i].NFe` (`ACBrNFe.Classes.pas`).
Todos os comandos usam `IF NOT EXISTS`, podendo ser executados a cada abertura do banco.
Os comandos são separados por `;` (`Delimiter`).

### CriarTabelas

```pascal
procedure CriarTabelas;
```

Cria as tabelas e índices da NFe executando o script de `sqlCreateTables`.
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
