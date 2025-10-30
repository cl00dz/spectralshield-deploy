# 🚀 SpectralShield Deployment Repository

This repository automatically builds and publishes the SpectralShield Docker image.

It contains the automation workflow responsible for packaging and updating the SpectralShield container image.

---

## ✅ What this repo does

| Job | Description |
|---|---|
🐳 Builds the SpectralShield Docker image  
📦 Pushes the image to GitHub Container Registry (GHCR)  
🔁 Keeps releases up to date automatically  

This repo lets you **self-host SpectralShield easily** by pulling the built image.

---

## 📦 Requirements

To use this project:

- Docker installed (if self-hosting locally)
- GitHub account (if you want to fork & auto-build your own version)

---

## 🧰 Getting Started

### 👉 Option 1: Use our Docker image

Pull the latest image:

```bash
docker pull ghcr.io/YOUR_GITHUB_USERNAME/spectralshield:latest
