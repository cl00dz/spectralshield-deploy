#!/usr/bin/env bash
set -euo pipefail

URL="$1"
ATTEMPTS="${2:-10}"
SLEEP_SECS="${3:-6}"

echo "Healthcheck: $URL (attempts=$ATTEMPTS)"
for i in $(seq 1 "$ATTEMPTS"); do
  if curl -fsS "$URL" >/dev/null; then
    echo "✅ Healthy"
    exit 0
  fi
  echo "… not ready (try $i/$ATTEMPTS), waiting ${SLEEP_SECS}s"
  sleep "$SLEEP_SECS"
done

echo "❌ Healthcheck failed"
exit 1

