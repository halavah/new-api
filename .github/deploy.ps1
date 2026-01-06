#!/usr/bin/env pwsh

# ============================================================================
# Git Deploy Tool (自动提交推送 - PowerShell)
# ============================================================================
# 功能说明：
#   自动执行 git 工作流：暂存 -> 提交 -> 拉取 -> 推送
#
# 工作流程：
#   1. 检测当前分支
#   2. 暂存所有更改（git add .）
#   3. 检查是否有更改需要提交
#      - 有更改：使用时间戳提交 -> 拉取 -> 推送
#      - 无更改：检查是否有未推送的提交
#        * 有未推送提交：拉取 -> 推送
#        * 无未推送提交：仅拉取
#   4. 自动处理远程更新
#
# 强制同步逻辑（当 git pull 失败时自动触发）：
#   ⚠️  检测到 Pull 失败 → 判断为远程历史可能被截断/重写
#   🔄 自动强制同步流程（在独立进程中执行）：
#      1. 切换到项目根目录的上一级目录（避免脚本自己被删除）
#      2. git fetch origin          - 获取远程最新状态
#      3. git reset --hard origin/分支 - 强制重置到远程分支
#      4. git clean -fd             - 删除所有未跟踪的文件
#   ✅ 结果：本地完全覆盖为远程状态，确保与远程完全一致
#   🛡️  脚本保护：从父目录执行，避免脚本文件被删除导致执行失败
#   💡 应用场景：
#      - 远程执行了 force push（如历史清理、分支重置）
#      - 远程历史被截断或重写（unrelated histories）
#      - 本地分支与远程完全不一致需要强制对齐
#
# 运行方式：
#   .\deploy.ps1
#
# 提交信息格式：
#   时间戳格式：yyyyMMdd_HHmmss
#   示例：20250122_143052
#
# 使用场景：
#   - 快速保存和同步代码更改
#   - 自动化日常提交推送操作
#   - 确保本地和远程保持同步
#   - 自动处理远程历史被强制推送的情况
#
# 注意事项：
#   - 会提交所有未暂存的更改
#   - 提交信息为时间戳，不包含详细描述
#   - 不会执行强制推送，保证远程历史安全
#   - 执行失败时会暂停3秒供查看错误信息
#   ⚠️  强制同步会完全覆盖本地更改和未跟踪文件
#   ⚠️  触发强制同步时，本地未提交的更改将会丢失
#   💡 如需保留本地更改，请在运行前先提交或备份
# ============================================================================

# Function to safely pull with fallback to force reset
function Invoke-SafePull {
    param([string]$Branch)

    Write-Host "Pulling latest changes from origin/$Branch..." -ForegroundColor Cyan
    git pull origin $Branch

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "⚠️  Pull failed. Detected possible history divergence." -ForegroundColor Yellow
        Write-Host "🔄 Initiating detached force sync..." -ForegroundColor Cyan
        Write-Host "The script will now close to allow safe file overwrites." -ForegroundColor Gray
        Write-Host ""

        # Get the parent directory of the project root (to avoid script being deleted)
        # Script is at: PROJECT_ROOT/.github/deploy.ps1
        # $PSScriptRoot is PROJECT_ROOT/.github
        # Parent of $PSScriptRoot is PROJECT_ROOT
        # Parent of PROJECT_ROOT is where we want to start
        $projectRoot = Resolve-Path "$PSScriptRoot\.."
        $parentDir = Split-Path -Parent $projectRoot
        $projectDirName = Split-Path -Leaf $projectRoot

        $command = "
            Write-Host '🔄 Force Syncing in detached process...' -ForegroundColor Cyan;
            Set-Location '$parentDir';
            Write-Host 'Changed to parent directory: $parentDir' -ForegroundColor Gray;
            Write-Host 'Fetching origin...' -ForegroundColor Gray;
            cd '$projectDirName';
            git fetch origin;
            if (`$?) {
                Write-Host 'Resetting to origin/$Branch...' -ForegroundColor Gray;
                git reset --hard origin/$Branch;
                Write-Host 'Cleaning untracked files...' -ForegroundColor Gray;
                git clean -fd;
                Write-Host '✅ Sync Complete! You can close this window.' -ForegroundColor Green;
                Read-Host 'Press Enter to exit';
            } else {
                Write-Host '❌ Fetch failed.' -ForegroundColor Red;
                Read-Host 'Press Enter to exit';
            }
        "

        # Start a new PowerShell process to run the command and exit this one immediately
        # Use -EncodedCommand to safely pass multi-line commands
        $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($command))
        Start-Process powershell -ArgumentList "-NoExit", "-EncodedCommand", $encodedCommand

        # Exit this script immediately so it doesn't crash when its file is deleted
        exit
    }

    return $true
}

# Navigate to project root
Set-Location "$PSScriptRoot\.."

# Get current branch
$currentBranch = git branch --show-current
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($currentBranch)) {
    Write-Host "Failed to detect current branch." -ForegroundColor Red
    Start-Sleep -Seconds 3
    return
}
Write-Host "Current branch: $currentBranch" -ForegroundColor Yellow
Write-Host ""

# Stage all changes
Write-Host "Staging all changes..." -ForegroundColor Cyan
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to stage changes." -ForegroundColor Red
    Start-Sleep -Seconds 3
    return
}

# Check if there are changes to commit
git diff --staged --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "No changes to commit." -ForegroundColor Green

    # Check if there are unpushed commits
    $unpushedCommits = git log origin/$currentBranch..$currentBranch 2>$null
    if ($unpushedCommits) {
        Write-Host "Found unpushed commits. Syncing with remote..." -ForegroundColor Yellow

        # Pull first
        $pullSuccess = Invoke-SafePull -Branch $currentBranch
        if (-not $pullSuccess) {
            Write-Host "Failed to sync with remote." -ForegroundColor Red
            Start-Sleep -Seconds 3
            return
        }

        # Push unpushed commits
        Write-Host "Pushing unpushed commits to origin/$currentBranch..." -ForegroundColor Cyan
        git push origin $currentBranch
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to push changes." -ForegroundColor Red
            Start-Sleep -Seconds 3
            return
        }

        Write-Host "[OK] Unpushed commits successfully pushed." -ForegroundColor Green
        Start-Sleep -Seconds 3
        return
    }

    # If no changes and no unpushed commits, just pull
    $pullSuccess = Invoke-SafePull -Branch $currentBranch
    if (-not $pullSuccess) {
        Write-Host "Failed to sync with remote." -ForegroundColor Red
    }
    Start-Sleep -Seconds 3
    return
}

# Commit changes with timestamped message
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Write-Host "Committing changes with timestamp: $timestamp..." -ForegroundColor Cyan
git commit -m "$timestamp"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to commit changes." -ForegroundColor Red
    Start-Sleep -Seconds 3
    return
}

# Pull latest changes from the remote repository
$pullSuccess = Invoke-SafePull -Branch $currentBranch
if (-not $pullSuccess) {
    Write-Host "Failed to sync with remote." -ForegroundColor Red
    Start-Sleep -Seconds 3
    return
}

# Push changes to the repository
Write-Host "Pushing changes to origin/$currentBranch..." -ForegroundColor Cyan
git push origin $currentBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to push changes." -ForegroundColor Red
    Start-Sleep -Seconds 3
    return
}

Write-Host ""
Write-Host "[OK] Changes successfully pulled, committed, and pushed." -ForegroundColor Green
Start-Sleep -Seconds 3
