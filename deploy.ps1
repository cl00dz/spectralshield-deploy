# SpectralShield Windows Deployment Script

# Ensure script runs from its own folder (supports double-click in Explorer)
Set-Location -Path $PSScriptRoot

Write-Host "`n🚀 Starting SpectralShield deployment..." -ForegroundColor Cyan

function ProgramExists {
    param($program)
    return (Get-Command $program -ErrorAction SilentlyContinue) -ne $null
}

Write-Host "🔍 Checking for Docker Desktop..." -ForegroundColor Yellow

$dockerPath = "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
$dockerInstalled = Test-Path $dockerPath

if (-not $dockerInstalled) {
    Write-Host "🐳 Docker Desktop not found — installing..." -ForegroundColor Red
    $installer = "$env:TEMP\DockerInstaller.exe"
    Invoke-WebRequest "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -OutFile $installer
    
    Start-Process $installer -ArgumentList "install --quiet" -Wait
    Write-Host "✅ Docker Desktop installed" -ForegroundColor Green

    Write-Host "🔄 Launching Docker Desktop for initial setup..." -ForegroundColor Yellow
    Start-Process "$dockerPath"
    Write-Host "📌 Reboot may be required after first Docker install" -ForegroundColor Magenta
} else {
    Write-Host "✅ Docker Desktop already installed" -ForegroundColor Green
}

Write-Host "▶️ Starting Docker Desktop..." -ForegroundColor Yellow
Start-Process "$dockerPath" | Out-Null
Start-Sleep -Seconds 5

Write-Host "⏳ Waiting for Docker Engine..." -ForegroundColor Yellow

$maxRetries = 60
$retry = 0

while ($retry -lt $maxRetries) {
    if (ProgramExists "docker") {
        docker info > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker Engine ready!" -ForegroundColor Green
            break
        }
    }
    Start-Sleep -Seconds 2
    $retry++
}

if ($retry -ge $maxRetries) {
    Write-Host "❌ Docker failed to start" -ForegroundColor Red
    exit 1
}

# Create .env only if missing
if (-not (Test-Path ".env")) {
@"
PORT=8080
"@ | Out-File ".env" -Encoding UTF8

Write-Host "🧾 Created default .env file" -ForegroundColor Green
}

Write-Host "📦 Pulling latest SpectralShield image..." -ForegroundColor Yellow
docker pull ghcr.io/cl00dz/spectralshield:latest

Write-Host "🚀 Launching SpectralShield container..." -ForegroundColor Yellow
docker stop spectralshield 2>$null
docker rm spectralshield 2>$null

docker run -d `
  --name spectralshield `
  -p 8080:80 `
  ghcr.io/cl00dz/spectralshield:latest | Out-Null

Write-Host "✅ SpectralShield container running!" -ForegroundColor Green

# Create shortcuts
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"

$ws = New-Object -ComObject WScript.Shell

$shortcutDesktop = "$desktop\SpectralShield.lnk"
$sc1 = $ws.CreateShortcut($shortcutDesktop)
$sc1.TargetPath = "http://localhost:8080"
$sc1.Save()

$shortcutMenu = "$startMenu\SpectralShield.lnk"
$sc2 = $ws.CreateShortcut($shortcutMenu)
$sc2.TargetPath = "http://localhost:8080"
$sc2.Save()

Write-Host "✅ Shortcuts created successfully" -ForegroundColor Green

# Launch Browser
Start-Process "http://localhost:8080"

Write-Host "`n🎧 SpectralShield is ready at http://localhost:8080`n" -ForegroundColor Cyan
