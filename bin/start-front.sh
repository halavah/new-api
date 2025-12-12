// 说明：仅启动前端 dev（默认 5173），不会启动后端。
// 若需后端，请单独运行 start-backend.sh（端口 3000）。
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v bun >/dev/null 2>&1; then
  echo "bun not found, please install bun (https://bun.sh)" >&2
  exit 1
fi

WEB_PORT="${WEB_PORT:-5173}"

if [ ! -d "web/node_modules" ]; then
  echo "Installing frontend dependencies (first run only)..."
  (cd web && bun install)
fi

echo "Starting frontend..."
cd web
exec bun run dev -- --host 0.0.0.0 --port "$WEB_PORT" "$@"

