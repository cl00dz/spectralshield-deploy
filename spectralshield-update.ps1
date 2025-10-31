# SpectralShield Update Script
Set-Location -Path $PSScriptRoot

Write-Host "`n🔄 Updating SpectralShield..." -ForegroundColor Cyan

function CheckDocker {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Docker is not installed. Please run deploy.ps1 first." -ForegroundColor Red
        exit 1
    }
}

CheckDocker

Write-Host "📦 Pulling latest container..." -ForegroundColor Yellow
docker pull ghcr.io/cl00dz/spectralshield:latest

Write-Host "⛔ Stopping existing container..." -ForegroundColor Yellow
docker stop spectralshield 2>$null
docker rm spectralshield 2>$null

Write-Host "🚀 Starting updated container..." -ForegroundColor Yellow
docker run -d `
  --name spectralshield `
  -p 8080:80 `
  ghcr.io/cl00dz/spectralshield:latest | Out-Null

Write-Host "✅ SpectralShield updated & restarted!" -ForegroundColor Green

Start-Process "http://localhost:8080"
Write-Host "🎧 Running latest version at http://lo
