# NFeStudio
Visualização, impressão de DANFe e relatórios em um aplicativo só

## Estrutura do projeto

```
NFeStudio/
├── src/                    # Código-fonte Lazarus
│   ├── nfestudio.lpi       # Projeto Lazarus (build modes, pacotes)
│   ├── nfestudio.lpr       # Programa principal
│   ├── nfestudio.ico       # Ícone da aplicação
│   ├── nfestudio.res       # Recursos compilados (ícone, manifest)
│   ├── ufrmmain.pas/.lfm   # Formulário principal (frmMain)
│   └── udmdnfe.pas/.lfm    # Data module da NF-e (dmdNFe)
├── images/                 # Imagens do projeto
│   ├── icons/
│   ├── logos/
│   └── screenshots/
├── docs/                   # Documentação
│   ├── manual/             # Manual do usuário
│   └── dev/                # Documentação técnica
├── build/                  # Units compiladas (.ppu/.o) por plataforma
│   ├── win64/
│   └── linux64/
├── bin/                    # Executáveis finais por plataforma
│   ├── win64/
│   └── linux64/
├── packaging/
│   └── linux64/
│       ├── common/         # Arquivos comuns aos pacotes (.desktop)
│       ├── deb/
│       │   └── nfestudio/  # Árvore do pacote .deb (DEBIAN/control + usr/...)
│       └── rpm/            # _topdir do rpmbuild
│           ├── SPECS/      # nfestudio.spec
│           └── SOURCES/    # Binário, .desktop e ícone copiados antes do build
└── dist/                   # Pacotes gerados (.deb, .rpm, instalador win64)
```

O projeto (`src/nfestudio.lpi`) possui os seguintes *Build Modes*:

| Modo            | Target OS / CPU  | Widgetset | Unit output (`-FU`)         | Executável (`-o`)                    |
|-----------------|------------------|-----------|-----------------------------|--------------------------------------|
| Debug-Linux64   | linux / x86_64   | gtk2      | `../build/linux64/debug`    | `../bin/linux64/debug/nfestudio`     |
| Release-Linux64 | linux / x86_64   | gtk2      | `../build/linux64/release`  | `../bin/linux64/nfestudio`           |
| Debug-Win64     | win64 / x86_64   | win32     | `../build/win64/debug`      | `../bin/win64/debug/nfestudio.exe`   |
| Release-Win64   | win64 / x86_64   | win32     | `../build/win64/release`    | `../bin/win64/nfestudio.exe`         |

- **Debug**: sem otimização, informação de debug DWARF3 (`-gw3 -gl`), heaptrc (`-gh`),
  checagens de range/overflow/IO/stack (`-CirotR`), assertions e `-dDEBUG`.
- **Release**: otimização `-O3`, smart linking (`-CX -XX`), sem informação de debug e
  com símbolos removidos (`-Xs`), além de `-dRELEASE`.

Compilação pela linha de comando:

```sh
lazbuild --bm=Release-Linux64 src/nfestudio.lpi
lazbuild --bm=Release-Win64   src/nfestudio.lpi   # cross-compile (requer FPC x86_64-win64)
```

Os pacotes abaixo devem ser gerados a partir do modo **Release-Linux64**.

### Empacotamento (linux64)

```sh
# .deb
cp bin/linux64/nfestudio packaging/linux64/deb/nfestudio/usr/bin/
cp packaging/linux64/common/nfestudio.desktop packaging/linux64/deb/nfestudio/usr/share/applications/
cp images/icons/nfestudio.png packaging/linux64/deb/nfestudio/usr/share/icons/hicolor/256x256/apps/
dpkg-deb --build --root-owner-group packaging/linux64/deb/nfestudio dist/

# .rpm
cp bin/linux64/nfestudio packaging/linux64/common/nfestudio.desktop \
   images/icons/nfestudio.png packaging/linux64/rpm/SOURCES/
rpmbuild -bb --define "_topdir $PWD/packaging/linux64/rpm" packaging/linux64/rpm/SPECS/nfestudio.spec
mv packaging/linux64/rpm/RPMS/x86_64/*.rpm dist/
```
