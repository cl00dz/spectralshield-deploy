# 🚀 SpectralShield Deploy Repository

This repository automatically syncs code from the main SpectralShield repo and builds a container image on every commit.

It acts as the **deployment mirror + build pipeline**, producing the container used to run SpectralShield.

---

## ✅ What this repo does

| Job | Purpose |
|---|---|
🔁 Sync code from main repo | Always up to date  
🐳 Build Docker image | Ensures new code runs in container  
📦 Push to GitHub Container Registry | `ghcr.io/USERNAME/spectralshield:latest`  

---

## 📦 Requirements

Before using this:

- Fork this repo
- Fork the main code repo (or point to yours)

---

## 🔧 Setup

### 1️⃣ Fork this repository

Click “Fork” at the top of the page.

---

### 2️⃣ Add required GitHub Secrets

Go to:

**Settings → Secrets and Variables → Actions**

Add:

| Secret | Value |
|---|---|
`CODE_REPO_PAT` | PAT with read access to code repo  
`DEPLOY_REPO_PAT` | PAT with write access to deploy repo  
`GHCR_USERNAME` | Your GitHub username  
`GHCR_TOKEN` | Token with `packages:write`  

---

### 3️⃣ How to run

Auto-runs when the `main` branch updates.

Or run manually:

> GitHub → Actions → Sync Code & Build Image → **Run workflow**

---

### 4️⃣ Pull the image locally

```bash
docker pull ghcr.io/YOURUSERNAME/spectralshield:latest
