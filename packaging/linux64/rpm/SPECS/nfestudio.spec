Name:           nfestudio
Version:        0.1.0
Release:        1%{?dist}
Summary:        Visualização, impressão de DANFe e relatórios
License:        GPL-3.0-or-later
URL:            https://github.com/rdxdt/NFeStudio
BuildArch:      x86_64
Requires:       qt6pas

# O binário é compilado pelo Lazarus (bin/linux64) e copiado para SOURCES antes do rpmbuild
Source0:        nfestudio
Source1:        nfestudio.desktop
Source2:        nfestudio.png

%description
NFeStudio reúne visualização de NF-e, impressão de DANFe e relatórios
em um aplicativo só.

%install
install -Dm755 %{SOURCE0} %{buildroot}%{_bindir}/nfestudio
install -Dm644 %{SOURCE1} %{buildroot}%{_datadir}/applications/nfestudio.desktop
install -Dm644 %{SOURCE2} %{buildroot}%{_datadir}/icons/hicolor/256x256/apps/nfestudio.png

%files
%{_bindir}/nfestudio
%{_datadir}/applications/nfestudio.desktop
%{_datadir}/icons/hicolor/256x256/apps/nfestudio.png

%changelog
* Sun Nov 01 2026 Rodrigo P. <ropeetz@gmail.com> - 0.1.0-1
- Versão inicial
