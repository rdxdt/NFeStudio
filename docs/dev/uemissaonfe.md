# uemissaonfe

Regras de negócio da emissão de NF-e (modelo 55) e NFC-e (modelo 65), sem interface: montagem da nota,
regras automáticas por modelo e finalidade, cálculo de impostos e totais, validação, XML e envio à SEFAZ.
É usada pelo [frmEmissaoNFe](ufrmemissaonfe.md) e pode ser testada sem tela.

## TEmissaoNFe

```pascal
TEmissaoNFe = class(TComponent)
```

Trabalha sobre a primeira nota de `ACBrNFe.NotasFiscais` (propriedade `NFe`). O vínculo com o `TACBrNFe` é desfeito
automaticamente se o componente for destruído (`FreeNotification`). Sem `ACBrNFe` ou sem nota carregada, os métodos
geram exceção.

### Nova nota e emitente

| Método | Descrição |
|--------|-----------|
| `NovaNota(Ini)` | Limpa `NotasFiscais` e cria uma nota com: versão, modelo (`Geral.ModeloDF`), tipo de emissão (`Geral.FormaEmissao`) e ambiente (`WebServices.Ambiente`) da configuração do `ACBrNFe`; série 1, número 1, `cNF = 0`, natureza `VENDA`, saída interna presencial, finalidade normal, `verProc = NFeStudio`, sem frete. Chama `PreencherEmitente` e `AplicarRegrasModelo`. |
| `PreencherEmitente(Ini)` | Lê a seção `[Emitente]` do INI (mesmas chaves do [frmConfig](ufrmconfig.md)) para `NFe.Emit`, com país 1058/BRASIL. Também define `Ide.cUF` e `Ide.cMunFG` a partir da UF e do município do emitente. IEST, IM e CNAE não existem na configuração e são mantidos. |

`cNF = 0` faz o ACBr gerar o código numérico aleatório ao montar a chave (`GerarChaveAcesso`). A chave, o `cNF` e o
`cDV` são preenchidos em cada `GerarXML`.

### Regras automáticas

| Método | Quando usar | O que faz |
|--------|-------------|-----------|
| `AplicarRegrasModelo` | Ao trocar o modelo | **NFC-e:** saída (706), interna (707), consumidor final (716), finalidade normal (715), sem data de saída (705), presença 1 ou 4 (717), DANFE 4 ou 5 (709), emissão normal ou off-line (782/783), sem referências (708), destinatário não contribuinte e sem IE/SUFRAMA (729/730), sem IE-ST (718), sem frete na venda presencial (753) e sem cobrança (760). **NF-e:** DANFE NFC-e vira retrato (710), entrega a domicílio vira presencial (794) e off-line vira normal (711). |
| `AplicarRegrasFinalidade` | Ao trocar a finalidade | Ajuste e devolução: substitui os pagamentos por um único "90 - Sem pagamento" (MOC YA02-20, rejeição 871). Fora da nota de débito/crédito limpa `tpNFDebito`/`tpNFCredito`; fora da devolução zera `pDevol` e `vIPIDevol` dos itens. |
| `DefinirDestinoOperacao` | Ao trocar a UF do destinatário (só NF-e) | `EX` → exterior; mesma UF do emitente ou venda presencial → interna (venda presencial a não residente, rejeição 773); demais → interestadual. |

### Itens

| Método | Descrição |
|--------|-----------|
| `NovoItem` | Adiciona um item numerado, com `SEM GTIN` e `indTot = 1`. Repete CFOP, origem, CST/CSOSN, modalidade e alíquotas de ICMS/PIS/COFINS do item anterior. No primeiro item: CFOP 1102 (entrada), 5102, 6102 ou 7102 (saída interna, interestadual ou exterior); regime normal CST 00 e PIS/COFINS 01; Simples Nacional CSOSN 102 e PIS/COFINS 49. |
| `RenumerarItens` | Refaz `nItem` em sequência após exclusões. |
| `CalcularItem(Det)` | Calcula os valores do item a partir das quantidades e alíquotas informadas (ver abaixo). |

`CalcularItem`:

- `vProd = qCom × vUnCom` quando quantidade e unitário são maiores que zero (a complementar de valor mantém o `vProd` informado).
- Sem unidade tributável própria, `uTrib`/`qTrib`/`vUnTrib` repetem os comerciais (rejeição 630).
- Base = `vProd − vDesc + vFrete + vSeg + vOutro`.
- ICMS próprio só para CST 00, 10, 20, 51, 70 e 90 (CSOSN 900 no Simples): `vBC = Base × (1 − pRedBC%)`, `vICMS = vBC × pICMS%`; FCP sobre a mesma base.
- Crédito do Simples (`vCredICMSSN`) para CSOSN 101, 201 e 900.
- IPI: `vBC = vProd + frete + seguro + outros`, `vIPI = vBC × pIPI%`.
- ICMS-ST para CST 10, 30, 70 e 90 (CSOSN 201, 202, 203 e 900): `vBCST = (Base + vIPI) × (1 + MVA%) × (1 − pRedBCST%)`, `vICMSST = vBCST × pICMSST% − vICMS` (nunca negativo).
- PIS, COFINS, IBS estadual, IBS municipal e CBS: sobre a Base, quando a alíquota é maior que zero.
- Valores arredondados com `RoundABNT` em 2 casas.

As bases de PIS/COFINS e IBS/CBS são simplificadas (não excluem o ICMS nem outros tributos). Para operações em que a
legislação exige outra base, ajuste os valores do item depois de calcular.

### Totais

`CalcularTotais` refaz `Total.ICMSTot` e `Total.IBSCBSTot` a partir dos itens, com as mesmas regras de soma do
`ValidarRegrasdeNegocios` do ACBr (rejeições 531 a 610):

- Frete, seguro, outros, desconto, II, IPI, IPI devolvido, ICMS desonerado, PIS, COFINS, tributos aproximados e IBS/CBS
  somam todos os itens.
- vBC, vICMS, vBCST, vST, FCP, FCP-ST e vProd somam só os itens com `indTot = 1`.
- `vNF = vProd + vST + vFrete + vSeg + vOutro + vII + vIPI + vFCPST + vIPIDevol − vDesc − vICMSDeson`.
- Na finalidade normal, `pag.vTroco` recebe o que os pagamentos excederem `vNF`.

### XML

| Método | Descrição |
|--------|-----------|
| `CarregarXML(Arquivo)` | Carrega NF-e/NFC-e, assinada, autorizada (`nfeProc`) ou rascunho. Num lote (`enviNFe`) mantém só a primeira nota. Arquivo sem nota gera exceção. |
| `SalvarXML(Arquivo)` | Gera o XML **sem assinatura** e grava, mesmo com pendências de validação (rascunho). |

O XML segue as opções do `ACBrNFe`, por exemplo `RetirarAcentos` e, em homologação, a troca do nome do destinatário
por "NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL".

### Validação

```pascal
function Validar(Erros, Avisos: TStrings): Boolean;
```

Retorna `True` sem erros. Os avisos não bloqueiam. Mensagens no formato `Grupo: mensagem`.

Regras próprias (complementam as do ACBr):

| Grupo | Regra |
|-------|-------|
| Identificação | Natureza obrigatória; número 1 a 999.999.999; série 0 a 999; data de emissão; saída/entrada não anterior à emissão |
| Identificação | Contingência (tipo de emissão diferente de normal) exige data/hora de entrada e justificativa de 15 a 256 caracteres |
| Identificação | Intermediador: obrigatório o indicador nas operações não presenciais (presença 2, 3, 4 e 9) e proibido nas demais; com intermediador, CNPJ válido e identificador obrigatórios |
| Identificação | Nota de crédito/débito exige o tipo de crédito/débito e é exclusiva da NF-e |
| Emitente | CNPJ/CPF válido, razão social, IE válida para a UF, endereço completo, município com 7 dígitos, UF válida |
| Destinatário | NF-e exige CNPJ/CPF ou identificação de estrangeiro (NFC-e aceita consumidor não identificado) |
| Destinatário | CNPJ/CPF válido e nome; contribuinte exige IE válida; isento não informa IE; não contribuinte exige consumidor final (rejeição 696) |
| Itens | De 1 a 990 itens; código, descrição, unidade; NCM com 8 dígitos (ou `00` para serviço); CFOP com 4 dígitos |
| Itens | Primeiro dígito do CFOP compatível com tipo e destino: entrada 1/2/3, saída 5/6/7; interna 1/5, interestadual 2/6, exterior 3/7 |
| Itens | Quantidade e valor unitário maiores que zero, exceto em complementar e ajuste |
| Itens | Percentual devolvido entre 0 e 100; IPI devolvido só na devolução |
| Itens (aviso) | Na devolução, CFOP fora da lista `CFOPS_DEVOLUCAO` |
| Pagamento | Ajuste só com "90 - Sem pagamento" (a devolução é validada pelo ACBr, 871); "90" com valor zero; "99 - Outros" com descrição; cartão de crédito/débito com tipo de integração |

Em seguida chama `GerarXML` (para montar a chave) e `NotaFiscal.ValidarRegrasdeNegocios` do ACBr. As rejeições
retornadas entram como erros do grupo `SEFAZ` (ex.: `SEFAZ: 321-Rejeição: NF-e devolução não possui NF referenciada`).
Entre outras, o ACBr verifica as regras da NFC-e, as referências da complementar (254, 255, 269, 678) e da devolução
(321), GTIN, NCM, CST incompatível com o destinatário, totais (531 a 610), pagamentos e troco (865 a 871), fatura e
duplicatas (851 a 902).

A lista `CFOPS_DEVOLUCAO` só gera aviso, pois os CFOPs aceitos na devolução variam com a legislação. Revise-a se
precisar de CFOPs específicos.

### Emissão

```pascal
function Emitir: TResultadoEmissao;
```

Gera o XML, chama `PrepararEnvio` (assina com o certificado e valida o schema) e `EnviarSEFAZ` (envio síncrono com
`ACBrNFe.Enviar(nNF, False, True)`, obrigatório na NFC-e). Retorna `cStat`/`xMotivo` do protocolo ou, sem
protocolo, do retorno do lote. Também retorna a chave e o número do protocolo. `Autorizada` é verdadeiro para
`cStat` 100 e 150. Erros de certificado, schema e comunicação são propagados como exceção.

A validação de regras não é feita aqui. Quem chama deve validar antes (o form chama `Validar`).

`PrepararEnvio` e `EnviarSEFAZ` são protegidos e virtuais para os testes substituírem certificado e webservice por
um mock.

### Funções

| Função | Descrição |
|--------|-----------|
| `EhCFOPDevolucao(CFOP)` | CFOP está em `CFOPS_DEVOLUCAO` |
| `EhSimplesNacional(NFe)` | CRT 1, 2 ou 4 (usa CSOSN no ICMS) |

Constantes `MODELO_NFE` (55) e `MODELO_NFCE` (65).

## Testes

`tests/tstemissaonfe.pas` (projeto `tests/nfestudiotests.lpi`). Usa um `TACBrNFe` configurado em homologação/SP,
um INI em memória com o emitente do XML de exemplo e `TEmissaoNFeMock`, que sobrescreve `PrepararEnvio` (sem
certificado) e `EnviarSEFAZ` (devolve o `cStat` configurado). Cobre: nova nota e emitente, regras de NFC-e/NF-e,
finalidade, destino da operação, padrões de item, cálculo (inclusive ST), totais e troco, nota válida segundo as
regras próprias e as do ACBr, CFOP incompatível, devolução sem referência, ajuste com pagamento, IE do destinatário,
intermediador, nota de crédito, XML salvo e recarregado e emissão autorizada e rejeitada.
