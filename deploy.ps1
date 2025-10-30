# SpectralShield Deployment Script (Windows)
Write-Host "🚀 Starting SpectralShield deployment..." -ForegroundColor Cyan

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker is not installed or not in PATH." -ForegroundColor Red
    Write-Host "➡️ Install Docker Desktop: https://www.docker.com/products/docker-desktop/"
    exit 1
}

# Check Docker Compose (Docker Desktop includes it)
if (-not (docker compose version)) {
    Write-Host "❌ Docker Compose not found." -ForegroundColor Red
    exit 1
}

# Prompt for GitHub username if GHCR_USERNAME isn't set
if (-not $env:GHCR_USERNAME) {
    $username = Read-H
