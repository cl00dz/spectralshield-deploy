# SpectralShield Windows Deployment Script
Write-Host "🚀 Starting SpectralShield deployment..." -ForegroundColor Cyan

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
    
    Write-Host "🔄 Launching Docker Desktop for first-time setup..." -ForegroundColor Yellow
    Start-Process "$dockerPath"
    Write-Host "📌 You may need to reboot after Docker finishes initial setup." -ForegroundColor Magenta
} else {
    Write-Host "✅ Docker Desktop already installed" -ForegroundColor Green
}

Write-Host "▶️ Starting Docker Desktop..." -ForegroundColor Yellow
Start-Process "$dockerPath"
Start-Sleep -Seconds 5

Write-Host "⏳ Waiting for Docker Engine to start..." -ForegroundColor Yellow

$maxRetries = 60
$retry = 0

while ($retry -lt $maxRetries) {
    if (ProgramExists "docker") {
        docker info > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker Engine Ready!" -ForegroundColor Green
            break
        }
    }
    Start-Sleep -Seconds 2
    $retry++
}

if ($retry -ge $maxRetries) {
    Write-Host "❌ Docker failed to start." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path ".env")) {
@"
# SpectralShield default config
PORT=8080
"@ | Out-File ".env"
Write-Host "🧾 Created default .env file" -ForegroundColor Green
}

Write-Host "📦 Pulling SpectralShield container..." -ForegroundColor Yellow
docker pull ghcr.io/cl00dz/spectralshield:latest

Write-Host "🚀 Starting SpectralShield container..." -ForegroundColor Yellow
docker stop spectralshield 2>$null
docker rm spectralshield 2>$null

docker run -d `
  --name spectralshield `
  -p 8080:80 `
  ghcr.io/cl00dz/spectralshield:latest

Write-Host "✅ SpectralShield container running!" -ForegroundColor Green

$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"

$shortcutDesktop = "$desktop\SpectralShield.lnk"
$shortcutMenu = "$startMenu\SpectralShield.lnk"

$ws = New-Object -ComObject WScript.Shell

$sc1 = $ws.CreateShortcut($shortcutDesktop)
$sc1.TargetPath = "http://localhost:8080"
$sc1.Save()

$sc2 = $ws.CreateShortcut($shortcutMenu)
$sc2.TargetPath = "http://localhost:8080"
$sc2.Save()

Write-Host "✅ Shortcuts created!" -ForegroundColor Green

Start-Process "http://localhost:8080"
Write-Host "🎧 SpectralShield is ready at: http://localhost:8080" -ForegroundColor Cyan
