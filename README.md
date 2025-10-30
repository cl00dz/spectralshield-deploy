<p align="center">
  <img src="assets/download.svg" width="120" />
</p>

<h1 align="center">SpectralShield</h1>
<p align="center"><b>Self-Hosted Audio Watermarking Engine</b></p>

<p align="center">Protect your audio. Own your IP. Keep your files private.</p>

<p align="center">
  <a href="#">Website</a> •
  <a href="#">Docs</a> •
  <a href="https://github.com/cl00dz/spectralshield-deploy/releases">Releases</a> •
  <a href="#-installation">Installation</a>
</p>

---

## 🎯 Overview

**SpectralShield** is an offline, self-hosted audio watermarking engine for:

- Music producers & labels  
- Audio engineers & studios  
- Podcasters & content creators  

Your files never leave your system — **no cloud, no telemetry, no tracking.**

✅ Local processing  
✅ Invisible forensic watermarking  
✅ Private & secure  

---

## ✨ Features

| Capability | Description |
|---|---|
🔒 Offline only | Zero cloud dependency  
🎵 Invisible audio watermarks | Forensic traceability  
🪟 PowerShell installer | Auto-provisions Docker Desktop  
🐳 Docker runtime | Portable & isolated  
⚙️ Auto-start | Launches Docker + runs container  

---

## 📦 Requirements

| Requirement | Details |
|---|---|
Platform | Windows 10/11  
Docker | Automatically installed if missing  
Port | Default `8080`  

---

## 🚀 Installation (Windows PowerShell)

SpectralShield installs and runs itself via Docker.  
If Docker Desktop is **not installed**, the script will **download & install it automatically**.  
If Docker Desktop **is installed**, it will **launch it and start the SpectralShield container**.

```powershell
git clone https://github.com/cl00dz/spectralshield-deploy.git
cd spectralshield-deploy
./deploy.ps1
