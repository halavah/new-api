# 说明：仅启动后端（go run main.go），不会启动前端 dev。
# 日志中的 Local/Network (3000) 是后端自带静态站点提示，不代表前端 dev 已启动；如需前端，请运行 start-front.ps1（默认 5173）。

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
Push-Location $RootDir

try {
    $port = if ($env:PORT) { $env:PORT } else { "3000" }

    if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
        Write-Host "Go not found, please install Go toolchain"
        exit 1
    }

    $portProcess = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Where-Object { $_.State -eq "Listen" } | Select-Object -ExpandProperty OwningProcess
    if ($portProcess) {
        Write-Host "Killing process on port $port (PID $($portProcess))..."
        Stop-Process -Id $portProcess -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Starting backend..."
    go run main.go $args

} finally {
    Pop-Location
}
