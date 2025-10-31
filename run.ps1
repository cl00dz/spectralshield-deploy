Write-Host "🚀 Starting SpectralShield Offline WebUI..."

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Docker Desktop not installed. Install it first:"
    Write-Error "   https://www.docker.com/products/docker-desktop/"
    exit 1
}

docker compose pull
docker compose up -d

Write-Host "✅ SpectralShield is running!"
Write-Host "➡  Open: http://localhost:8080"
Pause
]