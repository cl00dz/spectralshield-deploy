<#
SpectralShield Advanced Deployment Script (Windows)
Runs container, detects Docker, saves config, auto-updates.
#>

$ErrorActionPreference = "Stop"

Write-Host "🚀 SpectralShield Advanced Deployment" -ForegroundColor Cyan
Write-Host "----------------------------------------"

# GitHub repo info
$RepoOwner = "cl00dz"
$RepoName  = "spectralshield-deploy"
$ConfigFile = "$PSScriptRoot\deploy-config.json"

function Save-Config {
    param($Username)
    $obj = @{ GHCR_USERNAME = $Username }
    $obj | ConvertTo-Json | Out-File $ConfigFile -Encoding utf8
}

function Load-Config {
    if (Test-Path $ConfigFile) {
        return (Get-Content $ConfigFile | ConvertFrom-Json)
    }
    return $null
}

function Check-Docker {
    Write-Host "🔍 Checking Docker installation..." -ForegroundColor Yellow

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        try { docker info | Out-Null; return "docker" }
        catch { Write-Host "⚠ Docker installed but not running" -ForegroundColor Red }
    }

    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        Write-Host "🐧 Trying Docker via WSL..." -ForegroundColor Yellow
        try { wsl docker info | Out-Null; return "wsl" }
        catch {}
    }

    Write-Host "❌ Docker not found or not running." -ForegroundColor Red
    Write-Host "➡ Install Docker Desktop: https://www.docker.com/products/docker-desktop/"
    exit 1
}

function Start-DockerDesktop {
    if (-not (Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue)) {
        Write-Host "▶ Starting Docker Desktop..." -ForegroundColor Yellow
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        Write-Host "⏳ Waiting for Docker to start..."
        Start-Sleep -Seconds 12
    }
}

function Get-LatestRelease {
    $url = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
    try {
        $release = Invoke-RestMethod -Uri $url -UseBasicParsing
        return $release.tag_name
    } catch {
        return $null
    }
}

function Update-Script {
    $latest = Get-LatestRelease
    if (-not $latest) { return }

    if (Test-Path "./VERSION") {
        $local = Get-Content "./VERSION"
        if ($local -eq $latest) { return }
    }

    Write-Host "⬆ Updating to newest release ($latest)..." -ForegroundColor Yellow
    
    $zipUrl = "https://github.com/$RepoOwner/$RepoName/archive/refs/tags/$latest.zip"
    Invoke-WebRequest $zipUrl -OutFile "update.zip"

    Expand-Archive "update.zip" -DestinationPath "./update-temp" -Force
    Copy-Item "./update-temp/*/*" "./" -Recurse -Force

    Remove-Item "update.zip"
    Remove-Item "./update-temp" -Recurse

    $latest | Out-File "./VERSION"
    Write-Host "✅ Updated! Please rerun script." -ForegroundColor Green
    exit
}

# Auto-update check
Update-Script

# Load saved GHCR username if exists
$config = Load-Config
if ($config -and $config.GHCR_USERNAME) {
    $GH_USER = $config.GHCR_USERNAME
    Write-Host "✅ Using saved GHCR username: $GH_USER" -ForegroundColor Green
} else {
    $GH_USER = Read-Host "👤 Enter your GitHub username for container registry"
    Save-Config $GH_USER
    Write-Host "💾 Saved for future runs." -ForegroundColor Cyan
}

# Ensure Docker Desktop running
Start-DockerDesktop
$dockerEnv = Check-Docker

# Ensure .env exists
if (-not (Test-Path ".env")) {
@"
HOST_PORT=8080
"@ | Out-File -Encoding utf8 .env
Write-Host "⚙ Created .env with default settings (8080)" -ForegroundColor Cyan
} else {
    Write-Host "✅ Found .env file" -ForegroundColor Green
}

Write-Host "📦 Pulling latest container..." -ForegroundColor Yellow
if ($dockerEnv -eq "docker") { docker pull ghcr.io/$GH_USER/spectralshield:latest }
else { wsl docker pull ghcr.io/$GH_USER/spectralshield:latest }

Write-Host "🚀 Running container..." -ForegroundColor Yellow
if ($dockerEnv -eq "docker") { docker compose up -d }
else { wsl docker compose up -d }

Write-Host ""
Write-Host "✅ SpectralShield is now running!" -ForegroundColor Green
Write-Host "🌐 Access it at: http://localhost:8080"
Write-Host ""
Write-Host "🛠 To edit port, modify .env"
Write-Host "⭐ Leave a star if this helped you! https://github.com/$RepoOwner/$RepoName"
