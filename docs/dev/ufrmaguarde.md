# ufrmaguarde

Diálogo de espera com barra de progresso, exibido durante processamentos longos e síncronos.
Usado pelo `TProcessadorNFe` na importação de XML quando `ExibirProgresso = True`
(ver [uprocessadornfe](uprocessadornfe.md)).

## TfrmAguarde

### Uso

```pascal
frmAguarde := TfrmAguarde.Create(Self);
try
  frmAguarde.Exibir;            // ou Exibir('Mensagem personalizada')
  for I := 1 to Total do
  begin
    frmAguarde.AtualizarProgresso(I, Total);
    Application.ProcessMessages;
    // processa o item I
  end;
finally
  FreeAndNil(frmAguarde);
end;
```

O form não é criado automaticamente em `nfestudio.lpr`; quem chama cria e libera.

### Comportamento

- `Exibir(Mensagem)`: substitui o texto de `lblMensagem` (se informado), muda o cursor para
  `crHourGlass`, desabilita o `Application.MainForm`, exibe o form não modal e força sua pintura
  (`Update` + `Application.ProcessMessages`).
- `AtualizarProgresso(Atual, Total)`: ajusta `pgbProgresso` e escreve "X de Y arquivos" em `lblProgresso`.
  Não chama `ProcessMessages`; isso fica a cargo de quem processa.
- `FormDestroy`: reabilita o form principal e restaura o cursor (`crDefault`).
- O form principal fica desabilitado porque o `ProcessMessages` executaria cliques nele durante o
  processamento (ex.: iniciar uma segunda importação).
- Sem botões nem ícones de borda (`BorderIcons = []`), `fsStayOnTop` e centralizado no form principal
  (`poMainFormCenter`).

### Controles

| Controle      | Descrição                                               |
|---------------|---------------------------------------------------------|
| `pnlFundo`    | Painel com margem de 16px que agrupa os textos          |
| `lblTitulo`   | Título em negrito ("Importando arquivos XML")           |
| `lblMensagem` | Mensagem de espera, com quebra de linha                 |
| `pgbProgresso`| Barra de progresso (`Max` = total, `Position` = atual)  |
| `lblProgresso`| Texto "X de Y arquivos", alinhado à direita             |
