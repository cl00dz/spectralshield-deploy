Name: spectrashield
Version: 1.0.0
Release: 1%{?dist}
Summary: Self-hosted audio watermarking app
License: MIT
URL: https://github.com/cl00dz/spectralshield-deploy
BuildArch: x86_64
Requires: docker, docker-compose-plugin

%description
Launcher to deploy SpectraShield via Docker Compose.

%install
mkdir -p %{buildroot}/usr/share/spectrashield
mkdir -p %{buildroot}/usr/bin
cp -a deploy.sh %{buildroot}/usr/share/spectrashield/
echo '#!/bin/sh
cd /usr/share/spectrashield && ./deploy.sh
' > %{buildroot}/usr/bin/spectrashield
chmod 755 %{buildroot}/usr/bin/spectrashield

%files
/usr/share/spectrashield/deploy.sh
/usr/bin/spectrashield

