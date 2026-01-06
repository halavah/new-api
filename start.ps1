# ========================================
# New API - 管理脚本 (Windows PowerShell)
# ========================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BinDir = Join-Path $ScriptDir "bin"

# 检查 bin 目录是否存在
if (-not (Test-Path $BinDir)) {
    Write-Host "[错误] bin 目录不存在: $BinDir" -ForegroundColor Red
    Read-Host "按任意键退出"
    exit 1
}

function Show-MainMenu {
    Clear-Host
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗"
    Write-Host "║  New API - 管理控制台"
    Write-Host "╚════════════════════════════════════════════════════════════╝"
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════"
    Write-Host "   项目管理"
    Write-Host "═══════════════════════════════════════════════════════════"
    Write-Host ""
    Write-Host "   1. 🚀 启动后端     (bin\start-backend.ps1)"
    Write-Host ""
    Write-Host "   2. 🎨 启动前端     (bin\start-front.ps1)"
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════"
    Write-Host ""
    Write-Host "   9. 🚪 退出"
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════"
    Write-Host ""
}

function Invoke-StartBackend {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗"
    Write-Host "║  执行: 启动后端"
    Write-Host "╚════════════════════════════════════════════════════════════╝"
    Write-Host ""
    & (Join-Path $BinDir "start-backend.ps1") @args
    Show-WaitMenu
}

function Invoke-StartFront {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗"
    Write-Host "║  执行: 启动前端"
    Write-Host "╚════════════════════════════════════════════════════════════╝"
    Write-Host ""
    & (Join-Path $BinDir "start-front.ps1") @args
    Show-WaitMenu
}

function Show-WaitMenu {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════"
    Read-Host "按 Enter 键继续"
}

# 主循环
while ($true) {
    Show-MainMenu
    $choice = Read-Host "请选择操作 [1-2, 9]"

    switch ($choice) {
        "1" { Invoke-StartBackend }
        "2" { Invoke-StartFront }
        "9" {
            Write-Host ""
            Write-Host "[信息] 感谢使用 Libra Boot Plus 管理控制台"
            Write-Host ""
            exit 0
        }
        default {
            Write-Host ""
            Write-Host "[错误] 无效的选项: $choice" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}
