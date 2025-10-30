# SpectraShield Minimal Deployment (Windows)
$ErrorActionPreference = "Stop"

Write-Host "=== Installing SpectraShield ===" -ForegroundColor Cyan

# Ensure execution policy allows scripts
try {
    if ((Get-ExecutionPolicy) -eq 'Restricted') {
        Write-Host "Execution policy restricted. Updating..." -ForegroundColor Yellow
        Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
        Write-Host "Restart this script." -ForegroundColor Green
        exit
    }
} catch {
    Write-Host "Unable to modify execution policy. Run this manually:" -ForegroundColor Red
    Write-Host "  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force"
    exit
}

# Start Docker if installed
$dockerDesktopPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker not detected."

    if (Test-Path $dockerDesktopPath) {
        Write-Host "Starting Docker Desktop..." -ForegroundColor Yellow
        Start-Process $dockerDesktopPath
        Start-Sleep -Seconds 10
    } else {
        Write-Host "Install Docker Desktop first:" -ForegroundColor Red
        Write-Host "https://www.docker.com/products/docker-desktop"
        exit
    }
}

# Wait for Docker to be ready
for ($i = 1; $i -le 10; $i++) {
    try {
        docker info | Out-Null
        break
    } catch {
        Write-Host "Waiting for Docker..." -ForegroundColor Yellow
        Start-Sleep 3
    }
}

# Create .env if missing
if (-not (Test-Path ".env")) {
    "HOST_PORT=8080" | Out-File .env -Encoding utf8
    Write-Host "Created .env (HOST_PORT=8080)" -ForegroundColor Yellow
}

# Pull public image
Write-Host "Pulling SpectraShield from GHCR..." -ForegroundColor Cyan
docker pull ghcr.io/cl00dz/spectralshield:latest

# Run container
Write-Host "Starting SpectraShield..." -ForegroundColor Cyan
docker compose up -d

# Read port
$port = "8080"
if (Test-Path ".env") {
    $portLine = (Get-Content ".env") | Where-Object { $_ -match "^HOST_PORT=" }
    if ($portLine) { $port = $portLine.Split("=")[1] }
}

Write-Host ""
Write-Host "✅ SpectraShield is now running!" -ForegroundColor Green
Write-Host "Open: http://localhost:$port"
Write-Host ""
