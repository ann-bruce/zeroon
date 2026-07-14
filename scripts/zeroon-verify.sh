#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JAVA_HOME_DEFAULT="/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home"
API_BASE_URL="${ZEROON_API_BASE_URL:-http://127.0.0.1:8080/api/v1}"

usage() {
  cat <<'EOF'
Usage:
  scripts/zeroon-verify.sh backend|mobile|admin|api|all|quick

Checks:
  backend  ./gradlew test
  mobile   flutter analyze && flutter test
  admin    npm run lint && npm run build
  api      OpenAPI lint when available, backend health smoke test when running
  all      backend + mobile + admin + api + git diff --check
  quick    api + git diff --check

Environment:
  JAVA_HOME              Java home for backend. Defaults to local Corretto 17 path.
  ZEROON_API_BASE_URL   API base URL. Defaults to http://127.0.0.1:8080/api/v1.
EOF
}

java_home() {
  if [[ -n "${JAVA_HOME:-}" ]]; then
    echo "${JAVA_HOME}"
  else
    echo "${JAVA_HOME_DEFAULT}"
  fi
}

run_backend() {
  echo "== backend: ./gradlew test =="
  (
    cd "${ROOT_DIR}/backend"
    export JAVA_HOME="$(java_home)"
    export PATH="${JAVA_HOME}/bin:${PATH}"
    ./gradlew test
  )
}

run_mobile() {
  echo "== mobile: flutter analyze =="
  (cd "${ROOT_DIR}/mobile" && flutter analyze)
  echo "== mobile: flutter test =="
  (cd "${ROOT_DIR}/mobile" && flutter test)
}

run_admin() {
  echo "== admin: npm run lint =="
  (cd "${ROOT_DIR}/admin" && npm run lint)
  echo "== admin: npm run build =="
  (cd "${ROOT_DIR}/admin" && npm run build)
}

run_openapi_lint() {
  local spec="${ROOT_DIR}/docs/04_API/OpenAPI_V1.yaml"
  if [[ ! -f "${spec}" ]]; then
    echo "api: OpenAPI spec not found: ${spec}"
    return 0
  fi

  if command -v npx >/dev/null 2>&1; then
    echo "== api: redocly lint =="
    (cd "${ROOT_DIR}" && npx --yes @redocly/cli lint docs/04_API/OpenAPI_V1.yaml)
  else
    echo "api: skipped OpenAPI lint because npx is not available"
  fi
}

run_health_smoke() {
  local health_url="${API_BASE_URL%/}/system/health"
  echo "== api: health smoke ${health_url} =="

  if ! command -v curl >/dev/null 2>&1; then
    echo "api: skipped health smoke because curl is not available"
    return 0
  fi

  local response
  response="$(curl -fsS --max-time 5 "${health_url}" 2>/dev/null || true)"
  if [[ -z "${response}" ]]; then
    echo "api: backend is not reachable; start it with scripts/zeroon-service.sh start backend"
    return 0
  fi

  printf '%s\n' "${response}"
}

run_api() {
  run_openapi_lint
  run_health_smoke
}

run_diff_check() {
  echo "== git: diff --check =="
  (cd "${ROOT_DIR}" && git diff --check)
}

main() {
  if [[ $# -ne 1 ]]; then
    usage
    exit 2
  fi

  case "$1" in
    backend) run_backend ;;
    mobile) run_mobile ;;
    admin) run_admin ;;
    api) run_api ;;
    quick) run_api; run_diff_check ;;
    all) run_backend; run_mobile; run_admin; run_api; run_diff_check ;;
    *) echo "Unknown target: $1" >&2; usage; exit 2 ;;
  esac
}

main "$@"
