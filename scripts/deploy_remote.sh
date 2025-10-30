#!/usr/bin/env bash
set -euo pipefail

# Usage:
# ./deploy_remote.sh --host 1.2.3.4 --user ubuntu --key key.pem \
#   --remote-dir /opt/spectralshield --compose deploy/docker-compose.prod.yml \
#   --image ghcr.io/USER/spectralshield:TAG

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --host) HOST="$2"; shift;;
    --user) USER="$2"; shift;;
    --key) KEY="$2"; shift;;
    --remote-dir) REMOTE_DIR="$2"; shift;;
    --compose) COMPOSE_FILE="$2"; shift;;
    --image) IMAGE="$2"; shift;;
    *) echo "Unknown param: $1"; exit 1;;
  esac; shift
done

TMP=".deploy.$$"
mkdir -p "$TMP"
cp "$COMPOSE_FILE" "$TMP/docker-compose.yml"

# replace placeholder image with the immutable tag
sed -i "s|REPLACED_BY_CI|${IMAGE}|g" "$TMP/docker-compose.yml"

# copy compose to server & deploy
scp -i "$KEY" -o StrictHostKeyChecking=no "$TMP/docker-compose.yml" "${USER}@${HOST}:${REMOTE_DIR}/docker-compose.yml"

ssh -i "$KEY" -o StrictHostKeyChecking=no "${USER}@${HOST}" bash -lc "
  set -e
  cd ${REMOTE_DIR}
  docker compose pull || true
  docker compose up -d
  docker image prune -f || true
"

rm -rf "$TMP"
echo "✅ Deployed ${IMAGE} to ${HOST}:${REMOTE_DIR}"

