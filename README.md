# 🎧 SpectraShield — Self-Hosted Audio Watermarking

SpectraShield helps you embed invisible watermarks into audio — privately, on your own machine.  
No cloud. No telemetry. Your files never leave your system.

---

## 🚀 Install (Pick one)

### 🪟 Windows
- Download the latest **SpectraShield-Installer.exe** from Releases
- Run the installer (creates Start Menu & Desktop shortcuts)
- Or run portable script:
  ```powershell
  ./deploy.ps1
🍏 macOS

With Homebrew (after tap is published):

brew tap cl00dz/spectrashield
brew install spectrashield

Or from ZIP:
chmod +x deploy.sh
./deploy.sh

🐧 Linux

Debian/Ubuntu (.deb once published) or RPM for Fedora/RHEL

Or from ZIP:

chmod +x deploy.sh
./deploy.sh

🌐 Use

After install:

App runs at http://localhost:8080

Default port is 8080 (change via .env)

Update anytime:

./deploy.sh
# or
./deploy.ps1


Stop:

docker compose down


Uninstall:

docker compose down then delete the folder (or remove the package).

⚙️ Requirements

Docker Desktop (Windows/macOS) or Docker Engine (Linux)

Docker Compose plugin

🧩 Files

deploy.sh / deploy.ps1 — one-command installer/runner

docker-compose.yml — container definition

assets/ — icons & branding

installers/ — packaging (Windows/macOS/Linux)

❤️ Support

Star ⭐ this repo if it helps

Open issues for bugs/feature requests

## 7) CI note (image naming)

Be sure your CI builds to: `ghcr.io/cl00dz/spectrashield:latest` (we previously used Spectral; now **Spectra**).

If you want, I can paste a **cleaned build workflow** next.
