#!/usr/bin/env bash
set -euo pipefail
IMAGE="$1"; shift
CONTEXT="${1:-.}"

docker build -t "${IMAGE}:latest" "${CONTEXT}"
docker push "${IMAGE}:latest"

