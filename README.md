# NFeStudio
Visualização, impressão de DANFe e relatórios em um aplicativo só

## Estrutura do projeto

```
NFeStudio/
├── src/                    # Código-fonte Lazarus (.lpi, .lpr)
│   ├── forms/              # Formulários (.pas + .lfm)
│   ├── units/              # Units de lógica / regras de negócio
│   └── resources/          # Recursos (.rc, .res, .ico, manifest)
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

Nos *Build Modes* do Lazarus, configure para cada plataforma:

| Modo    | Target OS / CPU  | Unit output (`-FU`) | Executável (`-o`)          |
|---------|------------------|---------------------|----------------------------|
| Win64   | win64 / x86_64   | `../build/win64`    | `../bin/win64/nfestudio`   |
| Linux64 | linux / x86_64   | `../build/linux64`  | `../bin/linux64/nfestudio` |

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
