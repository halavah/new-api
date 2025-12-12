:: 说明：仅启动后端（go run main.go），不会启动前端 dev。
:: 日志中的 Local/Network (3000) 是后端自带静态站点提示，不代表前端 dev 已启动；如需前端，请运行 start-front.bat（默认 5173）。
@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%.."
pushd "%ROOT_DIR%"

if "%PORT%"=="" set "PORT=3000"

where go >nul 2>nul
if %errorlevel% neq 0 (
  echo Go not found, please install Go toolchain
  popd
  exit /b 1
)

for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":%PORT% " ^| findstr LISTEN') do (
  echo Killing process on port %PORT% (PID %%p)...
  taskkill /F /PID %%p >nul 2>nul
)

echo Starting backend...
go run main.go %*

popd
endlocal

