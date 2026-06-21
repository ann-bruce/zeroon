#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DIR="${ROOT_DIR}/.run"
LOG_DIR="${RUN_DIR}/logs"
JAVA_HOME_DEFAULT="/Users/bruceann/Library/Java/JavaVirtualMachines/corretto-17.0.13/Contents/Home"
MOBILE_API_BASE_URL="${ZEROON_API_BASE_URL:-http://localhost:8080/api/v1}"

mkdir -p "${RUN_DIR}" "${LOG_DIR}"

usage() {
  cat <<'EOF'
Usage:
  scripts/zeroon-service.sh start|stop|restart|status backend|mobile|admin|all

Examples:
  scripts/zeroon-service.sh start backend
  scripts/zeroon-service.sh restart mobile
  scripts/zeroon-service.sh stop all
  scripts/zeroon-service.sh status all

Environment:
  JAVA_HOME              Java home for backend. Defaults to local Corretto 17 path.
  ZEROON_API_BASE_URL   API URL passed to Flutter mobile web.
EOF
}

pid_file() {
  echo "${RUN_DIR}/$1.pid"
}

log_file() {
  echo "${LOG_DIR}/$1.log"
}

java_major_version() {
  local java_home="$1"
  if [[ ! -x "${java_home}/bin/java" ]]; then
    echo "0"
    return
  fi
  "${java_home}/bin/java" -version 2>&1 \
    | awk -F '"' '/version/ { split($2, parts, "."); print parts[1]; exit }'
}

backend_java_home() {
  local candidate="${JAVA_HOME:-}"
  if [[ -n "${candidate}" ]] && [[ "$(java_major_version "${candidate}")" -ge 17 ]]; then
    echo "${candidate}"
    return
  fi

  if [[ "$(java_major_version "${JAVA_HOME_DEFAULT}")" -ge 17 ]]; then
    echo "${JAVA_HOME_DEFAULT}"
    return
  fi

  echo "No Java 17+ runtime found. Set JAVA_HOME to Java 17 or newer." >&2
  exit 1
}

service_port() {
  case "$1" in
    backend) echo "8080" ;;
    mobile) echo "4173" ;;
    admin) echo "5173" ;;
    *) return 1 ;;
  esac
}

port_pid() {
  local service="$1"
  local port
  port="$(service_port "${service}")"
  lsof -tiTCP:"${port}" -sTCP:LISTEN 2>/dev/null | head -n 1 || true
}

is_running() {
  local service="$1"
  local file
  file="$(pid_file "${service}")"
  [[ -f "${file}" ]] && kill -0 "$(cat "${file}")" 2>/dev/null
}

print_status() {
  local service="$1"
  local listened_pid
  listened_pid="$(port_pid "${service}")"
  if [[ -n "${listened_pid}" ]]; then
    echo "${service}: running pid=${listened_pid} port=$(service_port "${service}") log=$(log_file "${service}")"
  elif is_running "${service}"; then
    echo "${service}: starting pid=$(cat "$(pid_file "${service}")") log=$(log_file "${service}")"
  else
    echo "${service}: stopped"
  fi
}

wait_for_port() {
  local service="$1"
  local attempts="${2:-30}"
  for _ in $(seq 1 "${attempts}"); do
    if [[ -n "$(port_pid "${service}")" ]]; then
      print_status "${service}"
      return
    fi
    if [[ -f "$(pid_file "${service}")" ]] && ! is_running "${service}"; then
      echo "${service}: failed to start. See log: $(log_file "${service}")" >&2
      return 1
    fi
    sleep 1
  done
  echo "${service}: not ready yet. See log: $(log_file "${service}")" >&2
  return 1
}

stop_one() {
  local service="$1"
  if ! is_running "${service}"; then
    local unmanaged_pid
    unmanaged_pid="$(port_pid "${service}")"
    if [[ -n "${unmanaged_pid}" ]]; then
      echo "${service}: stopping unmanaged pid=${unmanaged_pid} port=$(service_port "${service}")"
      kill "${unmanaged_pid}" 2>/dev/null || true
      wait_until_stopped "${service}" "${unmanaged_pid}"
      rm -f "$(pid_file "${service}")"
      return
    fi
    rm -f "$(pid_file "${service}")"
    echo "${service}: already stopped"
    return
  fi

  local pid
  pid="$(cat "$(pid_file "${service}")")"
  echo "${service}: stopping pid=${pid}"
  kill "${pid}" 2>/dev/null || true

  wait_until_stopped "${service}" "${pid}"
  rm -f "$(pid_file "${service}")"
}

wait_until_stopped() {
  local service="$1"
  local pid="$2"
  for _ in {1..20}; do
    if ! kill -0 "${pid}" 2>/dev/null && [[ -z "$(port_pid "${service}")" ]]; then
      echo "${service}: stopped"
      return
    fi
    sleep 0.5
  done

  echo "${service}: force stopping pid=${pid}"
  kill -9 "${pid}" 2>/dev/null || true
}

start_backend() {
  if is_running backend; then
    print_status backend
    return
  fi

  local java_home
  java_home="$(backend_java_home)"
  echo "backend: starting on port 8080"
  nohup bash -c '
    cd "$1/backend"
    export JAVA_HOME="$2"
    export PATH="$JAVA_HOME/bin:$PATH"
    exec ./gradlew bootRun
  ' bash "${ROOT_DIR}" "${java_home}" >"$(log_file backend)" 2>&1 &
  echo "$!" >"$(pid_file backend)"
  wait_for_port backend 40
}

start_mobile() {
  if is_running mobile; then
    print_status mobile
    return
  fi

  echo "mobile: starting Flutter web on 127.0.0.1:4173"
  nohup bash -c '
    cd "$1/mobile"
    exec flutter run -d web-server \
      --web-hostname 127.0.0.1 \
      --web-port 4173 \
      --dart-define="ZEROON_API_BASE_URL=$2"
  ' bash "${ROOT_DIR}" "${MOBILE_API_BASE_URL}" >"$(log_file mobile)" 2>&1 &
  echo "$!" >"$(pid_file mobile)"
  wait_for_port mobile 40
}

start_admin() {
  if is_running admin; then
    print_status admin
    return
  fi

  echo "admin: starting Vite on 127.0.0.1:5173"
  nohup bash -c '
    cd "$1/admin"
    exec npm run dev -- --host 127.0.0.1 --port 5173
  ' bash "${ROOT_DIR}" >"$(log_file admin)" 2>&1 &
  echo "$!" >"$(pid_file admin)"
  wait_for_port admin 30
}

start_one() {
  case "$1" in
    backend) start_backend ;;
    mobile) start_mobile ;;
    admin) start_admin ;;
    *) echo "Unknown service: $1" >&2; usage; exit 2 ;;
  esac
}

for_each_service() {
  local action="$1"
  local target="$2"
  if [[ "${target}" == "all" ]]; then
    for service in backend mobile admin; do
      "${action}" "${service}"
    done
  else
    "${action}" "${target}"
  fi
}

main() {
  if [[ $# -ne 2 ]]; then
    usage
    exit 2
  fi

  local command="$1"
  local target="$2"

  case "${command}" in
    start) for_each_service start_one "${target}" ;;
    stop) for_each_service stop_one "${target}" ;;
    restart)
      for_each_service stop_one "${target}"
      for_each_service start_one "${target}"
      ;;
    status) for_each_service print_status "${target}" ;;
    *) echo "Unknown command: ${command}" >&2; usage; exit 2 ;;
  esac
}

main "$@"
