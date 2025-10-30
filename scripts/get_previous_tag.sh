#!/usr/bin/env bash
set -euo pipefail
REGISTRY_IMAGE="$1" # ghcr.io/USER/spectralshield
curl -s -H "Authorization: Bearer ${GH_TOKEN:-}" \
  https://ghcr.io/v2/${REGISTRY_IMAGE#ghcr.io/}/tags/list | jq -r '.tags[]' | sort -r

