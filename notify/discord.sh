#!/usr/bin/env bash
set -euo pipefail
WEBHOOK="$1"
shift
MSG="$*"
curl -s -H "Content-Type: application/json" -X POST -d "{\"content\": \"${MSG//\"/\\\"}\"}" "$WEBHOOK" >/dev/null

