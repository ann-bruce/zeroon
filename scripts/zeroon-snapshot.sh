#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_BASE_URL="${ZEROON_API_BASE_URL:-http://127.0.0.1:8080/api/v1}"

section() {
  printf '
== %s ==
' "$1"
}

port_status() {
  local name="$1"
  local port="$2"
  local pid=""
  pid="$(lsof -tiTCP:"${port}" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
  if [[ -n "${pid}" ]]; then
    printf '%s: listening port=%s pid=%s
' "${name}" "${port}" "${pid}"
  else
    printf '%s: not listening port=%s
' "${name}" "${port}"
  fi
}

cd "${ROOT_DIR}"

section "Project"
printf 'root: %s
' "${ROOT_DIR}"
printf 'current_state: %s
' "${ROOT_DIR}/CURRENT_STATE.md"

section "Git"
printf 'branch: '
git branch --show-current
printf 'status:
'
git status --short
printf 'recent commits:
'
git log --oneline -5

section "Services"
if [[ -x "${ROOT_DIR}/scripts/zeroon-service.sh" ]]; then
  "${ROOT_DIR}/scripts/zeroon-service.sh" status all || true
else
  echo "scripts/zeroon-service.sh is not executable"
fi

section "Ports"
port_status backend 8080
port_status mobile 4173
port_status admin 5173

section "Backend Health"
health_url="${API_BASE_URL%/}/system/health"
printf 'url: %s
' "${health_url}"
if command -v curl >/dev/null 2>&1; then
  curl -fsS --max-time 5 "${health_url}" || echo "backend health: unavailable"
else
  echo "curl is not available"
fi
printf '
'

section "Workflow Commands"
cat <<'EOF'
scripts/zeroon-service.sh status all
scripts/zeroon-service.sh start all
scripts/zeroon-service.sh restart mobile
scripts/zeroon-verify.sh quick
scripts/zeroon-verify.sh all
EOF
