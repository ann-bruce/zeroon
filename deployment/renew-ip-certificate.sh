#!/usr/bin/env bash

set -euo pipefail

DEPLOYMENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTBOT_BIN="${CERTBOT_BIN:-/opt/certbot/bin/certbot}"

"$CERTBOT_BIN" renew \
  --cert-name zeroon-ip \
  --config-dir "$DEPLOYMENT_DIR/letsencrypt/config" \
  --work-dir "$DEPLOYMENT_DIR/letsencrypt/lib" \
  --logs-dir "$DEPLOYMENT_DIR/letsencrypt/log" \
  --deploy-hook "cd '$DEPLOYMENT_DIR' && docker compose exec -T nginx nginx -s reload"
