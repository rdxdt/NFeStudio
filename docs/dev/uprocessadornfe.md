# uprocessadornfe

Importação de arquivos XML de NFe para o banco de dados, usando um `TACBrNFe` para ler os arquivos
e as queries de gravação do `dmdNFe` (`cmdInsNFe*` / `cmdDelNFe*`).

## TProcessadorNFe

```pascal
TProcessadorNFe = class(TComponent)
```

### Propriedades

| Propriedade | Tipo       | Descrição                                                              |
|-------------|------------|------------------------------------------------------------------------|
| `ACBrNFe`   | `TACBrNFe` | Componente usado para ler os XMLs. Obrigatório para `Importar`; o vínculo é desfeito automaticamente se o componente for destruído (`FreeNotification`). |
| `Log`       | `TStrings` | Arquivos e notas ignorados ou com erro na última importação, uma linha por ocorrência. |
| `ExibirProgresso` | `Boolean` | Padrão `False`. Quando `True`, `Importar` exibe o diálogo de espera com progresso (ver abaixo). |

### Importar

```pascal
function Importar(const Diretorio: string): integer;
```

Percorre `Diretorio` e todos os subdiretórios, importando os arquivos `.xml` (extensão sem diferenciar
maiúsculas/minúsculas). Retorna a quantidade de notas gravadas.

- Gera exceção se `ACBrNFe` não estiver atribuído ou se o diretório não existir.
- Links simbólicos de diretório não são seguidos, evitando recursão infinita.
- Um arquivo de lote (`enviNFe`) com várias notas tem todas elas importadas.
- `NotasFiscais` do `ACBrNFe` é limpo ao final.
- O XML original de cada nota (`NotasFiscais[I].XMLOriginal`, com o protocolo quando for `nfeProc`) é gravado em
  `NFE_CAB.XML`, para reimpressão da DANFE. Em lote (`enviNFe`) cada nota recebe somente o seu XML.

### AtualizarProtocolo

```pascal
function AtualizarProtocolo(const Chave: string): Boolean;
```

Completa com o protocolo de autorização uma nota importada somente assinada (XML sem `nfeProc`), que
na DANFE sairia como "não enviada para SEFAZ". Retorna `True` se a nota foi regravada com protocolo.

1. Lê o XML gravado em `NFE_CAB.XML`; sem XML retorna `False`.
2. Carrega a nota no `ACBrNFe`. Se ela já tiver protocolo (`procNFe.nProt`), retorna `False` sem consultar a SEFAZ.
3. Chama `ConsultarSEFAZ` (protegido e virtual), que executa `ACBrNFe.Consultar`. Com a nota carregada, o ACBr
   preenche `procNFe` e troca o `XMLOriginal` pelo `nfeProc`. A URL do webservice é definida pela chave
   (modelo e UF), independentemente de `Configuracoes.Geral.ModeloDF`.
4. Se a consulta devolver protocolo, regrava a nota pelo mesmo caminho da importação (substitui a versão
   gravada, atualizando `XML` e os campos `PROT_*`). Nota não autorizada (ex.: `cStat` 217, não consta na
   base) volta sem `nProt` e não é regravada.
5. `NotasFiscais` é limpo ao final.

- Gera exceção se `ACBrNFe` não estiver atribuído.
- Erros da consulta (certificado, comunicação, configuração) são propagados como exceção.

`ConsultarSEFAZ` existe para ser sobrescrito nos testes, que usam um mock no lugar do webservice real.

### Progresso (`ExibirProgresso`)

Com `ExibirProgresso = True`, `Importar`:

1. Cria e exibe um `TfrmAguarde` (ver [ufrmaguarde](../dev/ufrmaguarde.md)), que desabilita o form principal.
2. Conta os arquivos `.xml` com `ContarArquivos`, que segue os mesmos critérios de `ImportarDiretorio`
   (recursivo, sem seguir links simbólicos), para obter o total Y.
3. Antes de cada arquivo, `AtualizarProgresso` incrementa o arquivo atual X, atualiza a barra e o texto
   "X de Y arquivos" e chama `Application.ProcessMessages`, mantendo a interface responsiva.
4. Libera o diálogo ao final, inclusive em caso de exceção.

Com `ExibirProgresso = False` (padrão, usado nos testes) nenhum form é criado e `ProcessMessages` não é chamado.

Situações que não interrompem a importação e são registradas em `Log`:

| Situação                                     | Mensagem                                         |
|----------------------------------------------|--------------------------------------------------|
| XML que o ACBr não consegue ler como NFe (eventos, outros documentos, NFe sem atributo `Id`) | `arquivo ignorado, não foi possível ler a NFe`  |
| XML lido sem nenhuma NFe                      | `arquivo ignorado, não contém NFe`              |
| NFe sem `CHNFE` (`infNFe.Id` sem uma chave de 44 caracteres) | `NFe ignorada, sem CHNFE`          |
| Erro do banco ao gravar a nota                | `erro ao gravar a NFe`                          |

### Gravação de uma nota

Cada nota é gravada em uma transação própria da conexão do `dmdNFe`:

1. Exclui a nota existente com a mesma chave em todas as tabelas (`cmdDelNFe*`). Reimportar uma nota
   substitui a versão gravada; por exemplo, um XML com protocolo de autorização (`nfeProc`)
   atualiza os campos `PROT_*`. A exclusão é feita tabela a tabela porque o `ON DELETE CASCADE` depende
   de `PRAGMA foreign_keys`.
2. Insere `NFE_CAB`, `NFE_DET` (um registro por item), `NFE_FAT` (somente se houver fatura),
   `NFE_DUP`, `NFE_VOL` e `NFE_PAG` (`SEQ` = posição na coleção, iniciando em 1).
3. Em caso de erro, a transação é desfeita e a nota é registrada em `Log`.

### Conversão dos valores

| Tipo no DDL | Origem                              | Valor gravado como NULL                          |
|-------------|-------------------------------------|--------------------------------------------------|
| `VARCHAR`   | string ou enumerado (`*ToStr` do ACBr, mesmo código do XML) | texto vazio                |
| `INTEGER`   | inteiro                             | 0, somente em códigos opcionais (CEP, município, país, `cStat`, `cMsg`, `idCSRT` etc.) |
| `NUMERIC`   | `Currency`/`Double`                 | nunca (0 é gravado como 0)                       |
| `DATETIME`, `DATE`, `TIME` | `TDateTime`          | 0                                                |

Grupos opcionais do XML só são gravados quando presentes, seguindo as mesmas condições do
`TNFeXmlWriter` do ACBr. Quando ausentes, suas colunas ficam NULL. Isso evita gravar o valor padrão de um
enumerado como se fosse um código real (ex.: `IPI_CST = '00'` em item sem IPI). Entre eles:
`gCompraGov`, `Avulsa`, `Dest`, `Retirada`, `Entrega`, `retTransp`, `cana`, `guiaTransito`, `procNFe`,
`veicProd`, `comb`, `IPI`, `II`, `PISST`, `COFINSST`, `ISSQN`, `ICMSUFDest`, `IS`, `IBSCBS`,
`DFeReferenciado` e o grupo de cartão do pagamento (`tpIntegra`).

`ICMS_CST` é gravado quando o emitente é do regime normal (`CRT` 3 ou 2) e `ICMS_CSOSN` no Simples
Nacional (`CRT` 1 ou 4).

### Dependência da libxml2

O ACBr carrega a libxml2 pelo nome `libxml2.so` no Linux. Esse link é instalado pelo pacote de
desenvolvimento (`libxml2-dev`); sem ele, a leitura falha com "Não foi possível carregar a biblioteca
LibXml2" e todos os arquivos são registrados como ignorados.

## Testes

`tests/tstprocessadornfe.pas` (projeto `tests/nfestudiotests.lpi`, executável em `bin/linux64/tests`).
Os testes usam um banco SQLite temporário, o XML de exemplo em `tests/fixtures` (nfeProc 3.10) e uma NFe 4.00
do Simples Nacional com IBS/CBS gerada pelo próprio ACBr durante o teste.

`AtualizarProtocolo` é testado com `TProcessadorNFeMock`, que sobrescreve `ConsultarSEFAZ` e, em vez de acessar
a SEFAZ, carrega `ArquivoRetorno` (o nfeProc da fixture) como nota atualizada. Com `ArquivoRetorno` vazio, ele
simula uma consulta sem protocolo. A nota sem protocolo é a própria fixture recortada até `</NFe>`.

```sh
lazbuild tests/nfestudiotests.lpi
bin/linux64/tests/nfestudiotests
```
