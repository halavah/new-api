// 说明：仅启动后端（go run main.go），不会启动前端 dev。
// 日志中的 Local/Network (3000) 是后端自带静态站点提示，不代表前端 dev 已启动；如需前端，请运行 start-front.sh（默认 5173）。
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v go >/dev/null 2>&1; then
  echo "Go not found, please install Go toolchain" >&2
  exit 1
fi

echo "Starting backend..."
exec go run main.go "$@"

