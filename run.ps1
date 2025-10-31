Write-Host "🚀 Starting SpectralShield Offline WebUI..."

# Paths
$DockerExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
$InstallerPath = "$env:TEMP\DockerDesktopInstaller.exe"

# Function: Install Docker Desktop silently
function Install-DockerDesktop {
    Write-Host "📦 Downloading Docker Desktop Installer..."
    Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker Desktop Installer.exe" -OutFile $InstallerPath

    Write-Host "⚙️ Installing Docker Desktop silently (this may take a few minutes)..."
    Start-Process $InstallerPath -ArgumentList "install", "--quiet" -Wait

    Write-Host "✅ Docker Desktop installation completed!"

    # Detect if reboot required
    if (Test-Path "C:\ProgramData\DockerDesktop\install-log.txt") {
        $log = Get-Content "C:\ProgramData\DockerDesktop\install-log.txt"
        if ($log -match "(?i)reboot required|restart required") {
            Write-Warning "🔄 Docker Desktop requires a system reboot to complete setup."
            $choice = Read-Host "Would you like to reboot now? (Y/N)"
            if ($choice -match "^[Yy]$") {
                Write-Host "🔁 Rebooting system..."
                Restart-Computer
            } else {
                Write-Host "⚠️ Please reboot manually before running this script again."
                Read-Host "Press Enter to exit"
                exit 1
            }
        }
    }
}


# ✅ Check if Docker Desktop is installed
if (-not (Test-Path $DockerExe)) {
    Write-Warning "🐋 Docker Desktop is not installed."

    $choice = Read-Host "Install Docker Desktop automatically? (Y/N)"
    if ($choice -match "^[Yy]$") {
        Install-DockerDesktop
    } else {
        Write-Host "❌ Docker Desktop is required. Install from:"
        Write-Host "➡ https://www.docker.com/products/docker-desktop/"
        Read-Host "Press Enter to exit"
        exit 1
    }
}


# ✅ Ensure Docker runs
Write-Host "⏳ Checking Docker status..."

docker info 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "🐋 Starting Docker Desktop..."
    Start-Process $DockerExe
    
    $max = 60; $i = 0

    while ($i -lt $max) {
        Start-Sleep 2
        docker info 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker is ready!"
            break
        }
        Write-Host "⌛ Waiting for Docker... ($i/$max)"
        $i++
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ Docker failed to start."
        exit 1
    }
}


# ✅ Pull & launch container
Write-Host "📦 Pulling SpectralShield image..."
docker compose pull

Write-Host "🚀 Launching SpectralShield..."
docker compose up -d

Write-Host "✅ SpectralShield is running!"
Write-Host "➡ Open in browser: http://localhost:8080"
Read-Host "Press Enter to exit"
