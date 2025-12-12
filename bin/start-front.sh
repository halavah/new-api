#!/usr/bin/env bash
# // 说明：仅启动前端 dev（默认 5173），不会启动后端。
# // 若需后端，请单独运行 start-backend.sh（端口 3000）。
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# region agent log
log_front() {
  local ts
  ts=$(date +%s%3N 2>/dev/null || perl -MTime::HiRes=time -e 'printf("%.0f", time*1000)')
  echo '{"sessionId":"debug-session","runId":"pre-fix","hypothesisId":"H2","location":"bin/start-front.sh","message":"'"$1"'","data":{"cwd":"'"$(pwd)"'","args":"'"$*"'"},"timestamp":'"$ts"'}' >> "/Volumes/Samsung/software_yare/aquar-newapi/.cursor/debug.log"
}
# endregion agent log

log_front "entry" "$@"

if ! command -v bun >/dev/null 2>&1; then
  log_front "bun_missing"
  echo "bun not found, please install bun (https://bun.sh)" >&2
  exit 1
fi

WEB_PORT="${WEB_PORT:-5173}"

# 强制释放占用端口
if command -v lsof >/dev/null 2>&1; then
  PIDS=$(lsof -t -i :"$WEB_PORT" -sTCP:LISTEN 2>/dev/null | tr '\n' ' ')
  if [ -n "$PIDS" ]; then
    log_front "port_kill_attempt" "port=$WEB_PORT" "$PIDS"
    kill -9 $PIDS 2>/dev/null || true
    log_front "port_kill_done" "port=$WEB_PORT" "$PIDS"
    sleep 1
  fi
elif command -v nc >/dev/null 2>&1; then
  if nc -z localhost "$WEB_PORT" >/dev/null 2>&1; then
    log_front "port_kill_skipped_nc_detected" "port=$WEB_PORT"
    echo "Port $WEB_PORT seems in use; please free it or set WEB_PORT." >&2
    exit 1
  fi
else
  log_front "port_kill_skipped_no_tool" "port=$WEB_PORT"
fi

if command -v lsof >/dev/null 2>&1; then
  if lsof -i :"$WEB_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    log_front "port_still_in_use" "port=$WEB_PORT"
    echo "Port $WEB_PORT is still in use. Stop the existing process or change WEB_PORT." >&2
    exit 1
  fi
elif command -v nc >/dev/null 2>&1; then
  if nc -z localhost "$WEB_PORT" >/dev/null 2>&1; then
    log_front "port_still_in_use" "port=$WEB_PORT"
    echo "Port $WEB_PORT is still in use. Stop the existing process or change WEB_PORT." >&2
    exit 1
  fi
else
  log_front "port_check_skipped" "port=$WEB_PORT"
fi

if [ ! -d "web/node_modules" ]; then
  log_front "install_deps"
  echo "Installing frontend dependencies (first run only)..."
  (cd web && bun install)
fi

log_front "starting_frontend" "$WEB_PORT"
echo "Starting frontend..."
cd web
exec bun run dev -- --host 0.0.0.0 --port "$WEB_PORT" "$@"

