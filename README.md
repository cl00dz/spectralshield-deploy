# 🚀 SpectralShield Deploy Repository

This repository handles **automated deployment** of the SpectralShield app.

It syncs code from the main repo, builds a Docker image, pushes it to registry, and redeploys to your Portainer instance.

Perfect for:

- Self-hosting SpectralShield
- Automated CI/CD deployment
- Portainer-based homelab or production environments

---

## ✅ Features

| Feature | Description |
|--------|-------------|
🔄 **Auto-syncs from code repo** | Pulls latest code from main repo  
🐳 **Builds Docker image** | Uses GitHub Actions + GHCR  
☁️ **Deploys to Portainer** | Via webhook  
🔐 **Secure** | No secrets stored in repo  

---

## 📦 Requirements

Before using, you'll need:

- Docker / Portainer running somewhere
- GitHub account
- GitHub Container Registry token
- Portainer Webhook URL

---

## 🔧 Setup Instructions

### 1️⃣ **Fork this repo**

Click 👉 **Fork** in GitHub.

---

### 2️⃣ **Configure GitHub Secrets**

Go to:

> **Settings → Secrets → Actions**

Add these:

| Secret | Value |
|-------|-------|
`CODE_REPO_PAT` | GitHub PAT with repo read rights  
`DEPLOY_REPO_PAT` | GitHub PAT with repo write rights  
`GHCR_USERNAME` | Your GitHub username  
`GHCR_TOKEN` | GHCR token (packages:write)  
`PORTAINER_WEBHOOK` | Your Portainer webhook URL  

---

### 3️⃣ **Enable the Workflow**

In GitHub:

> **Actions → Enable Workflow**

You can then click **Run workflow** anytime.

---

### 4️⃣ **Portainer Setup**

Create a stack in Portainer using:

```yaml
version: "3.8"

services:
  spectralshield:
    image: ghcr.io/YOUR_GH_USERNAME/spectralshield:latest
    container_name: spectralshield_app
    ports:
      - "${HOST_PORT:-8080}:80"
    restart: unless-stopped
