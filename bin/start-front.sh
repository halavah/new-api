#!/usr/bin/env bash
# // 说明：仅启动前端 dev（默认 5173），不会启动后端。
# // 若需后端，请单独运行 start-backend.sh（端口 3000）。
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v bun >/dev/null 2>&1; then
  echo "bun not found, please install bun (https://bun.sh)" >&2
  exit 1
fi

WEB_PORT="${WEB_PORT:-5173}"

# 强制释放占用端口
if command -v lsof >/dev/null 2>&1; then
  PIDS=$(lsof -t -i :"$WEB_PORT" -sTCP:LISTEN 2>/dev/null | tr '\n' ' ')
  if [ -n "$PIDS" ]; then
    kill -9 $PIDS 2>/dev/null || true
    sleep 1
  fi
elif command -v nc >/dev/null 2>&1; then
  if nc -z localhost "$WEB_PORT" >/dev/null 2>&1; then
    echo "Port $WEB_PORT seems in use; please free it or set WEB_PORT." >&2
    exit 1
  fi
fi

if command -v lsof >/dev/null 2>&1; then
  if lsof -i :"$WEB_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Port $WEB_PORT is still in use. Stop the existing process or change WEB_PORT." >&2
    exit 1
  fi
elif command -v nc >/dev/null 2>&1; then
  if nc -z localhost "$WEB_PORT" >/dev/null 2>&1; then
    echo "Port $WEB_PORT is still in use. Stop the existing process or change WEB_PORT." >&2
    exit 1
  fi
fi

if [ ! -d "web/node_modules" ]; then
  echo "Installing frontend dependencies (first run only)..."
  (cd web && bun install)
fi

echo "Starting frontend..."
cd web
exec bun run dev -- --host 0.0.0.0 --port "$WEB_PORT" "$@"

