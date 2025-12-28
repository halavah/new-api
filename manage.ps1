#!/usr/bin/env pwsh

# 自动修复当前脚本的权限
$scriptPath = $MyInvocation.MyCommand.Path
if ($scriptPath) {
    try {
        # 尝试设置执行权限
        attrib +x $scriptPath 2>$null
        if ($?) {
            Write-Host "Script permissions fixed." -ForegroundColor Green
        }
    } catch {
        # 忽略权限检查错误，继续执行
    }
}

while ($true) {
    Clear-Host
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════"
    Write-Host "  项目管理"
    Write-Host "═══════════════════════════════════════════════════════════"
    Write-Host ""
    Write-Host "  0. 部署到 Git        (deploy.ps1)"
    Write-Host "     → 自动提交并推送代码到远程仓库"
    Write-Host ""
    Write-Host "  1. 清理 Git 跟踪     (clear-ignore.ps1)"
    Write-Host "     → 根据 .gitignore 移除已跟踪的文件"
    Write-Host ""
    Write-Host "  2. 压缩 Git 仓库     (clear-git.ps1)"
    Write-Host "     → 优化 .git 目录，减小体积（保留所有历史）"
    Write-Host ""
    Write-Host "  3. 清理 Git 历史     (clear-history.ps1)"
    Write-Host "     → 删除旧提交，仅保留最近 N 个（需谨慎）"
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════"
    Write-Host ""
    Write-Host "  9. 退出"
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════"
    Write-Host ""

    $choice = Read-Host "请选择操作 [0-3,9] (默认: 0 - 部署)"

    if ($choice -eq "") {
        $choice = "0"
    }

    switch ($choice) {
        "0" {
            Clear-Host
            Write-Host "Starting Deploy..." -ForegroundColor Cyan
            Write-Host ""
            & "$PSScriptRoot\bin\deploy.ps1"
            Write-Host ""
            Read-Host "按 Enter 返回主菜单"
        }
        "1" {
            Clear-Host
            Write-Host "Starting Clear Ignore..." -ForegroundColor Cyan
            Write-Host ""
            & "$PSScriptRoot\bin\clear-ignore.ps1"
            Write-Host ""
            Read-Host "按 Enter 返回主菜单"
        }
        "2" {
            Clear-Host
            Write-Host "Starting Clear Git..." -ForegroundColor Cyan
            Write-Host ""
            & "$PSScriptRoot\bin\clear-git.ps1"
            Write-Host ""
            Read-Host "按 Enter 返回主菜单"
        }
        "3" {
            Clear-Host
            Write-Host "Starting Clear History..." -ForegroundColor Cyan
            Write-Host ""
            & "$PSScriptRoot\bin\clear-history.ps1"
            Write-Host ""
            Read-Host "按 Enter 返回主菜单"
        }
        "9" {
            Write-Host ""
            Write-Host "再见！" -ForegroundColor Green
            exit 0
        }
        default {
            Write-Host ""
            Write-Host "错误: 无效的选项" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}
