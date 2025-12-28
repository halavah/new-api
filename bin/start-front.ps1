# 说明：仅启动前端 dev（默认 5173），不会启动后端。
# 若需后端，请单独运行 start-backend.ps1（端口 3000）。

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
Push-Location $RootDir

try {
    if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
        Write-Host "bun not found, please install bun (https://bun.sh)"
        exit 1
    }

    $webPort = if ($env:WEB_PORT) { $env:WEB_PORT } else { "5173" }

    $portProcess = Get-NetTCPConnection -LocalPort $webPort -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" } | Select-Object -ExpandProperty OwningProcess
    if ($portProcess) {
        Write-Host "Killing process on port $webPort (PID $($portProcess))..."
        Stop-Process -Id $portProcess -Force -ErrorAction SilentlyContinue
    }

    if (-not (Test-Path "web\node_modules")) {
        Write-Host "Installing frontend dependencies (first run only)..."
        Push-Location web
        bun install
        Pop-Location
    }

    Write-Host "Starting frontend..."
    Push-Location web
    bun run dev -- --host 0.0.0.0 --port $webPort $args
    Pop-Location

} finally {
    Pop-Location
}
