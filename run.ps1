Write-Host "`n🚀 Starting SpectralShield Offline WebUI..."

# Move to script directory so docker-compose.yml is found
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)

# Paths
$DockerExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
$InstallerPath = "$env:TEMP\DockerDesktopInstaller.exe"
$LogFile = "C:\ProgramData\DockerDesktop\install-log.txt"

function Install-DockerDesktop {
    Write-Host "📦 Downloading Docker Desktop installer..."
    Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker Desktop Installer.exe" -OutFile $InstallerPath

    Write-Host "⚙️ Installing Docker Desktop silently..."
    Start-Process $InstallerPath -ArgumentList "install", "--quiet" -Wait

    Write-Host "✅ Docker Desktop installation completed!"

    if (Test-Path $LogFile) {
        $log = Get-Content $LogFile
        if ($log -match "(?i)reboot required|restart required") {
            Write-Warning "🔄 Docker Desktop requires a system reboot."
            $choice = Read-Host "Reboot now? (Y/N)"
            if ($choice -match "^[Yy]$") {
                Restart-Computer
            } else {
                Write-Host "⚠️ Please reboot before running again."
                Read-Host "Press Enter to exit"
                exit
            }
        }
    }
}

# Check for Docker Desktop
if (-not (Test-Path $DockerExe)) {
    Write-Warning "🐋 Docker Desktop is not installed."
    $choice = Read-Host "Install Docker Desktop automatically? (Y/N)"
    if ($choice -match "^[Yy]$") {
        Install-DockerDesktop
    } else {
        Write-Host "❌ Docker Desktop required. Download from https://www.docker.com"
        Read-Host "Press Enter to exit"
        exit
    }
}

# Ensure Docker is running
Write-Host "⏳ Checking Docker status..."
docker info 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "🐋 Starting Docker Desktop..."
    Start-Process $DockerExe

    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Seconds 2
        docker info 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker is ready!"
            break
        }
        Write-Host "⌛ Waiting for Docker... ($i/60)"
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ Docker failed to start."
        exit 1
    }
}

# Run Docker Compose
Write-Host "📦 Pulling latest SpectralShield image..."
docker compose pull

Write-Host "🚀 Launching SpectralShield..."
docker compose up -d

Write-Host "`n✅ SpectralShield is running!"
Write-Host "➡️  Open in your browser: http://localhost:8080"
Read-Host "Press Enter to exit..."
