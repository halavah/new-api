:: 说明：仅启动前端 dev（默认 5173），不会启动后端。
:: 若需后端，请单独运行 start-backend.bat（端口 3000）。
@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%.."
pushd "%ROOT_DIR%"

where bun >nul 2>nul
if %errorlevel% neq 0 (
  echo bun not found, please install bun (https://bun.sh)
  popd
  exit /b 1
)

if "%WEB_PORT%"=="" set WEB_PORT=5173

if not exist web\node_modules (
  echo Installing frontend dependencies (first run only)...
  pushd web
  bun install
  popd
)

echo Starting frontend...
pushd web
bun run dev -- --host 0.0.0.0 --port %WEB_PORT% %*
popd

popd
endlocal

