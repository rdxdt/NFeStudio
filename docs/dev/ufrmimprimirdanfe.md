# ufrmimprimirdanfe

Janela que pergunta em qual modelo a DANFE será impressa. Não imprime nada: devolve a escolha para quem
chamou (ver `TfrmMain.ImprimirDANFE` em [ufrmmain](ufrmmain.md)).

## TTipoDANFE

| Valor      | Opção                                  | Componente usado no `frmMain`                        |
|------------|----------------------------------------|------------------------------------------------------|
| `tdPOS`    | DANFCe na impressora POS (ESC/POS)     | `ACBrNFeDANFeESCPOS1` (via `ACBrPosPrinter1`)        |
| `tdBobina` | DANFCe em bobina (Fortes)              | `ACBrNFeDANFCeFortes1`                               |
| `tdA4`     | DANFE em A4                            | NFC-e: `ACBrNFeDANFCeFortesA4_1`; NF-e: `ACBrNFeDANFeRL1` |

`MODELO_NFCE = 65` é declarado na interface da unit.

## TfrmImprimirDANFE

```pascal
if TfrmImprimirDANFE.Selecionar(Modelo, Padrao, Tipo) then
  // imprimir com Tipo
```

`Selecionar` cria o form, chama `Configurar`, exibe em modal e o libera. Retorna `True` se o usuário clicou
em **Imprimir**; `Tipo` recebe a opção marcada.

- `Configurar(Modelo, Padrao)`: para NFC-e (modelo 65) exibe as três opções e marca `Padrao`. Para qualquer
  outro modelo (NF-e) exibe somente A4 e a marca, ignorando `Padrao`. `lblModelo` mostra o modelo da nota.
- `TipoSelecionado`: opção marcada.

## Testes

`tests/tstfrmimprimirdanfe.pas`: opções visíveis e selecionadas para NF-e e NFC-e com cada padrão.
