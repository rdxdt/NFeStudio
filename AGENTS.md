# Guia do projeto NFeStudio

## Estrutura de diretórios
- `src/`: Código-fonte pascal e projeto Lazarus
- `images/`: Ícones, logos e screenshots do projeto
- `docs/`: Manual e documentação do projeto
- `build/`: Units compiladas por plataforma
- `bin/`: Binários montados por plataformas
- `packaging/`: Estrutura de arquivos para empacotamento em linux
- `dist/`: Pacotes gerados para instalação
- `tests/`: Projeto de testes (FPCUnit) e arquivos de apoio em `tests/fixtures`

## Componentes/bibliotecas utilizados
- ACBr
- Fortes Report
- Zeos DBO
- LCL

## Arquitetura da UI
- Componentes LCL com widgetset qt6 para linux e win32 para windows
- A UI deve ser minimalista e alinhada com princípios modernos

## Padrão de prefixos de nome de objetos
- `TForm`: frm
- `TLabel`: lbl
- `TPanel`: pnl
- `TButton`, TBitBtn, TSpeedButton: btn
- `TToolbar`: tbr
- `TToolButton`: tbt
- `TEdit`, `TDBEdit`: edt
- `TGroupBox`: grp
- `TStringGrid`,`TDBGrid`:grd
- `TDateTimePicker`: dtp
- `TZConnection`: con
- `TZQuery`: qry
- `TZQuery com comandos diferentes de SELECT`:cmd
- `TDataSource`: dts
- `TComboBox`: cbx
- `TCheckBox`: chk
- `TSpinEdit`: spe
- `TDirectoryEdit`, `TFileNameEdit`: edt
- `TPageControl`: pgc
- `TTabSheet`: tab
- `TScrollBox`: sbx

Deduza e adicione a lista outros componentes LCL.

## Regras do projeto
- Todo componente LCL deverá constar em seu respectivo form lfm e pas, evitando criação de componentes LCL por código(runtime).
- Toda query SQL deverá usar o componente TZQuery e conter seu conteúdo em sua propriedade SQL.
- Todo componente TZQuery deverá estar em seu datamodule relevante.
- Todas as palavras chaves de pascal deverão ser em letra minúscula.
- Primeira letra do nome de classes devera ser T maíusculo.
- Utilize Pascal case para nomear variaveis, classes.
- Utilize letras maiusculas para constantes.
- Utilize duas letras como prefixo para enums.
- Mantenha o código simples e idiomático.
- Comente o código em portugues brasileiro mas evite comentários para coisas óbvias, somente comente algo não obvio, constraint ou workaround.
- Cada unit deverá ter sua documentação criada e atualizada com um md para cada unit e dentro dela a documentação de classes

## Higiene de edição
- Mude somente o que é requerido
- Prefira o menor diff valido
- Não refatore códigos não relacionados
- Não faça edições somente de mudança de formatação
- Mantenha o estilo de nomes consistente com o código
- Atualize as documentações em caso de edição


## Seja minimamente invasivo
- Prefira adicionar funções ou bloco lógicos em torno do código existente em vez de reestruturar o código existente.
- Não extraia, ou altere a forma de código existente só para fazer funcionar o seu código; sempre olhe por mecanismos para deixar o código existente intacto.
- Aceite um pouco de duplicação em vez de reestruturar o código. Uma função que repete algumas linhas de uma existente é preferível sobre a alteração da estrutura do original.
- Coloque lógica nova em funções contidas no módulo dela.

## Verifique o escopo antes de tocar código existente
- Antes de mudar algo no código como estruturas, funções, tipos e propriedades ou a assinatura de uma classe, verifique se existe uso em outras partes e pergunte antes de alterar outras partes

## Testes
- Para cada módulo crie um conjunto de testes.
- Em casos de utilização de API e webservices externos faça um mockup em vez de utilizar o webservice real.
