#!/usr/bin/env bash
set -euo pipefail

echo "📦 Pulling latest SpectraShield image..."
: "${GHCR_USERNAME:=cl00dz}"
docker pull "ghcr.io/${GHCR_USERNAME}/spectrashield:latest"

if [ ! -f ".env" ]; then
  echo "HOST_PORT=8080" > .env
  echo "⚙️ Created .env (HOST_PORT=8080)"
fi

echo "🚀 Starting SpectraShield..."
docker compose up -d
echo "✅ Running at http://localhost:${HOST_PORT:-8080}"
