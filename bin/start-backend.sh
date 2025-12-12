#!/usr/bin/env bash
# // 说明：仅启动后端（go run main.go），不会启动前端 dev。
# // 日志中的 Local/Network (3000) 是后端自带静态站点提示，不代表前端 dev 已启动；如需前端，请运行 start-front.sh（默认 5173）。
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

PORT="${PORT:-3000}"

# 强制释放占用端口
if command -v lsof >/dev/null 2>&1; then
  PIDS=$(lsof -t -i :"$PORT" -sTCP:LISTEN 2>/dev/null | tr '\n' ' ')
  if [ -n "$PIDS" ]; then
    kill -9 $PIDS 2>/dev/null || true
    sleep 1
  fi
elif command -v nc >/dev/null 2>&1; then
  if nc -z localhost "$PORT" >/dev/null 2>&1; then
    echo "Port $PORT seems in use; please free it or set PORT." >&2
    exit 1
  fi
fi

if command -v lsof >/dev/null 2>&1; then
  if lsof -i :"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "Port $PORT is still in use. Stop the existing process or change PORT." >&2
    exit 1
  fi
elif command -v nc >/dev/null 2>&1; then
  if nc -z localhost "$PORT" >/dev/null 2>&1; then
    echo "Port $PORT is still in use. Stop the existing process or change PORT." >&2
    exit 1
  fi
fi

if ! command -v go >/dev/null 2>&1; then
  echo "Go not found, please install Go toolchain" >&2
  exit 1
fi

echo "Starting backend..."
exec go run main.go "$@"

