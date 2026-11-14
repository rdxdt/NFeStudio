# ufrmrelatorios

Form de opções de relatório, aberto pelo botão Relatórios do [frmMain](ufrmmain.md).

## TfrmRelatorios

```pascal
TfrmRelatorios = class(TForm)
```

Diálogo (`bsDialog`, centralizado no form principal, `AutoSize`) com um botão por relatório dentro do
`grpRelatorios` e o botão `btnFechar` no rodapé (`pnlBotoes`).

### Exibir

```pascal
class procedure Exibir;
```

Cria o form, mostra com `ShowModal` e o libera ao fechar.

### Relatórios

| Botão                | Ação                                                                      |
|----------------------|---------------------------------------------------------------------------|
| `btnTotaisSintetico` | `TrelTotaisSintetico.Exibir` (ver [ureltotalsintetico](ureltotalsintetico.md)) |

O form continua aberto depois de gerar um relatório (os botões de relatório têm `ModalResult = mrNone`),
permitindo gerar outro em seguida. `btnFechar` (`Cancel = True`, `ModalResult = mrCancel`) fecha o form,
assim como a tecla Esc.

Para incluir um relatório, adicione um `TButton` em `grpRelatorios`. O `ChildSizing` do group box
(um controle por linha, largura homogênea) posiciona o botão abaixo dos demais.

## Testes

`tests/tstfrmrelatorios.pas` (projeto `tests/nfestudiotests.lpi`). Confere que o botão do relatório
existe no `grpRelatorios` com `OnClick` ligado e sem fechar o form, e que `btnFechar` cancela o form.
O relatório em si é testado em `tstreltotalsintetico`.
