#!/usr/bin/env bash
set -e

echo "📦 Pulling latest SpectralShield image..."
docker pull ghcr.io/$GHCR_USERNAME/spectralshield:latest

echo "🚀 Starting container..."
docker compose up -d

echo "✅ SpectralShield is running!"
