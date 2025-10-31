# Enable script to run when double-clicked in Explorer
Set-ExecutionPolicy -Scope Process Bypass -Force

# Ensure script runs from its own directory
try {
    Set-Location -Path $PSScriptRoot
} catch { }

Write-Host "`n===== SpectralShield Installer =====" -ForegroundColor Cyan

function Check-Program($program) {
    return (Get-Command $program -ErrorAction SilentlyContinue) -ne $null
}

# Docker Desktop path
$dockerPath = "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"

Write-Host "🔍 Checking Docker Desktop..." -ForegroundColor Yellow
if (-not (Test-Path $dockerPath)) {
    Write-Host "🐳 Docker Desktop not found — installing..." -ForegroundColor Red
    $installer = "$env:TEMP\DockerInstaller.exe"
    Invoke-WebRequest "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile $installer
    Start-Process $installer -ArgumentList "install --quiet" -Wait
    Write-Host "✅ Docker Desktop installed — You may need to reboot after installation." -ForegroundColor Green
}

Write-Host "▶️ Launching Docker Desktop..." -ForegroundColor Yellow
Start-Process $dockerPath

Write-Host "⏳ Waiting for Docker engine to be ready..." -ForegroundColor Yellow

# Wait for Docker engine
for ($i=1; $i -le 60; $i++) {
    if (Check-Program "docker") {
        docker info > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker ready" -ForegroundColor Green
            break
        }
    }
    Start-Sleep -Seconds 2
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker did not start — try running manually once, then re-run installer" -ForegroundColor Red
    pause
    exit 1
}

# Create .env if missing
if (-not (Test-Path ".env")) {
@"
PORT=8080
"@ | Out-File ".env" -Encoding UTF8
Write-Host "🧾 Created .env" -ForegroundColor Green
}

Write-Host "📦 Pulling SpectralShield container..." -ForegroundColor Yellow
docker pull ghcr.io/cl00dz/spectralshield:latest

Write-Host "🚀 Starting container..." -ForegroundColor Yellow
docker stop spectralshield 2>$null
docker rm spectralshield 2>$null

# Launch container
Start-Process "docker" `
    -ArgumentList "run -d --name spectralshield -p 8080:80 ghcr.io/cl00dz/spectralshield:latest" `
    -NoNewWindow -Wait

Write-Host "✅ SpectralShield running" -ForegroundColor Green

# Create shortcuts
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$ws = New-Object -ComObject WScript.Shell

$shortcutDesktop = "$desktop\SpectralShield.lnk"
$desktopShortcut = $ws.CreateShortcut($shortcutDesktop)
$desktopShortcut.TargetPath = "http://localhost:8080"
$desktopShortcut.Save()

$shortcutMenu = "$startMenu\SpectralShield.lnk"
$menuShortcut = $ws.CreateShortcut($shortcutMenu)
$menuShortcut.TargetPath = "http://localhost:8080"
$menuShortcut.Save()

Write-Host "✅ Shortcuts created" -ForegroundColor Green

Start-Process "http://localhost:8080"

Write-Host "`n🎧 SpectralShield is ready at http://localhost:8080`n" -ForegroundColor Cyan
pause
