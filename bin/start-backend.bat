:: 说明：仅启动后端（go run main.go），不会启动前端 dev。
:: 日志中的 Local/Network (3000) 是后端自带静态站点提示，不代表前端 dev 已启动；如需前端，请运行 start-front.bat（默认 5173）。
@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%.."
pushd "%ROOT_DIR%"

where go >nul 2>nul
if %errorlevel% neq 0 (
  echo Go not found, please install Go toolchain
  popd
  exit /b 1
)

echo Starting backend...
go run main.go %*

popd
endlocal

