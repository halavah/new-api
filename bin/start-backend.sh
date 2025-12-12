#!/usr/bin/env bash
# // 说明：仅启动后端（go run main.go），不会启动前端 dev。
# // 日志中的 Local/Network (3000) 是后端自带静态站点提示，不代表前端 dev 已启动；如需前端，请运行 start-front.sh（默认 5173）。
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# region agent log
log_backend() {
  local ts
  ts=$(date +%s%3N 2>/dev/null || perl -MTime::HiRes=time -e 'printf("%.0f", time*1000)')
  echo '{"sessionId":"debug-session","runId":"pre-fix","hypothesisId":"H1","location":"bin/start-backend.sh","message":"'"$1"'","data":{"cwd":"'"$(pwd)"'","args":"'"$*"'"},"timestamp":'"$ts"'}' >> "/Volumes/Samsung/software_yare/aquar-newapi/.cursor/debug.log"
}
# endregion agent log

PORT="${PORT:-3000}"
log_backend "entry" "port=$PORT" "$@"

if command -v lsof >/dev/null 2>&1; then
  if lsof -i :"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    log_backend "port_in_use" "port=$PORT"
    echo "Port $PORT is in use. Stop the existing process or change PORT." >&2
    exit 1
  fi
elif command -v nc >/dev/null 2>&1; then
  if nc -z localhost "$PORT" >/dev/null 2>&1; then
    log_backend "port_in_use" "port=$PORT"
    echo "Port $PORT is in use. Stop the existing process or change PORT." >&2
    exit 1
  fi
else
  log_backend "port_check_skipped" "port=$PORT"
fi

if ! command -v go >/dev/null 2>&1; then
  log_backend "go_missing"
  echo "Go not found, please install Go toolchain" >&2
  exit 1
fi

log_backend "starting_backend"
echo "Starting backend..."
exec go run main.go "$@"

