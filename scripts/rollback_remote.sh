#!/usr/bin/env bash
set -euo pipefail

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

TMP=".rollback.$$"
mkdir -p "$TMP"
cp "$COMPOSE_FILE" "$TMP/docker-compose.yml"
sed -i "s|REPLACED_BY_CI|${IMAGE}|g" "$TMP/docker-compose.yml"

scp -i "$KEY" -o StrictHostKeyChecking=no "$TMP/docker-compose.yml" "${USER}@${HOST}:${REMOTE_DIR}/docker-compose.yml"

ssh -i "$KEY" -o StrictHostKeyChecking=no "${USER}@${HOST}" bash -lc "
  set -e
  cd ${REMOTE_DIR}
  docker compose pull || true
  docker compose up -d
"

rm -rf "$TMP"
echo "↩️ Rolled back to ${IMAGE}"

