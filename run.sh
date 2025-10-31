#!/usr/bin/env bash
echo "🚀 Starting SpectralShield Offline WebUI..."

if ! command -v docker &> /dev/null; then
  echo "❌ Docker not installed. Install Docker Desktop first:"
  echo "   https://www.docker.com/products/docker-desktop/"
  exit 1
fi

docker compose pull
docker compose up -d

echo "✅ SpectralShield is running!"
echo "➡  Open: http://localhost:8080"
