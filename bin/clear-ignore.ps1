#!/usr/bin/env pwsh

# ============================================================================
# Git Ignore Cleanup Tool (PowerShell)
# ============================================================================
# 功能说明：
#   根据 .gitignore 内容移除已被 Git 跟踪的文件
#
# 工作流程：
#   1. 检查是否在 Git 仓库中
#   2. 检查 .gitignore 文件是否存在
#   3. 查找被跟踪但应该被忽略的文件
#   4. 显示待移除的文件列表
#   5. 询问用户确认
#   6. 移除文件的 Git 跟踪（不删除本地文件）
#
# 运行方式：
#   .\clear-ignore.ps1
#
# 处理的模式：
#   - 常见构建目录：out/, .next/, node_modules/, build/, dist/
#   - 日志文件：*.log
#   - 环境配置文件：.env*
#   - 临时文件：*.tmp
#   - macOS 文件：.DS_Store
#   - 锁文件：package-lock.json, yarn.lock, pnpm-lock.yaml
#   - 测试覆盖率：coverage/
#   - 缓存目录：.cache/
#
# 注意事项：
#   - 只移除 Git 跟踪，不会删除本地文件系统中的文件
#   - 移除后需要提交更改才能生效
#   - 建议在执行前先提交当前更改
# ============================================================================

Write-Host "=========================================="
Write-Host "  根据 .gitignore 内容清理 Git 跟踪文件"
Write-Host "=========================================="
Write-Host ""

# Navigate to project root
Set-Location "$PSScriptRoot\.."

# Check if in a Git repository
Write-Host "检查 Git 仓库状态..." -ForegroundColor Cyan
$gitDir = git rev-parse --git-dir 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "错误：当前目录不是 Git 仓库" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

# Check if .gitignore exists
if (-not (Test-Path ".gitignore")) {
    Write-Host "错误：未找到 .gitignore 文件" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

Write-Host "[OK] Git 仓库和 .gitignore 文件检查通过" -ForegroundColor Green
Write-Host ""

# Create temp file path
$tempFile = Join-Path $env:TEMP "git_ignore_files.txt"

# Clear temp file if exists
if (Test-Path $tempFile) {
    Remove-Item $tempFile -Force
}

# Function to add files to temp list
function Add-IgnoredFiles {
    param(
        [string]$Pattern
    )

    $files = git ls-files | Select-String -Pattern $Pattern
    foreach ($file in $files) {
        $filePath = $file.Line.ToString()
        if (-not [string]::IsNullOrWhiteSpace($filePath)) {
            Add-Content -Path $tempFile -Value $filePath
        }
    }
}

Write-Host "第一步：查找被跟踪但应该被忽略的文件..." -ForegroundColor Cyan
Write-Host ""

# Method 1: Process common directory patterns
Write-Host "处理 out/ 目录..." -ForegroundColor Yellow
Add-IgnoredFiles "^out/"

Write-Host "处理 .next/ 目录..." -ForegroundColor Yellow
Add-IgnoredFiles "^\.next/"

Write-Host "处理 node_modules/ 目录..." -ForegroundColor Yellow
Add-IgnoredFiles "^node_modules/"

Write-Host "处理 build/ 目录..." -ForegroundColor Yellow
Add-IgnoredFiles "^build/"

Write-Host "处理 dist/ 目录..." -ForegroundColor Yellow
Add-IgnoredFiles "^dist/"

# Method 2: Process other common patterns
Write-Host ""
Write-Host "处理 .gitignore 中的其他模式..." -ForegroundColor Yellow

# Log files
Write-Host "处理日志文件..." -ForegroundColor Yellow
Add-IgnoredFiles "\.log$"

# Environment files
Write-Host "处理环境文件..." -ForegroundColor Yellow
Add-IgnoredFiles "^\.env"

# Temporary files
Write-Host "处理临时文件..." -ForegroundColor Yellow
Add-IgnoredFiles "\.tmp$"

# .DS_Store files
Write-Host "处理 .DS_Store 文件..." -ForegroundColor Yellow
Add-IgnoredFiles "\.DS_Store$"

# package-lock.json
Write-Host "处理 package-lock.json..." -ForegroundColor Yellow
Add-IgnoredFiles "package-lock\.json$"

# yarn.lock
Write-Host "处理 yarn.lock..." -ForegroundColor Yellow
Add-IgnoredFiles "yarn\.lock$"

# pnpm-lock.yaml
Write-Host "处理 pnpm-lock.yaml..." -ForegroundColor Yellow
Add-IgnoredFiles "pnpm-lock\.yaml$"

# coverage directory
Write-Host "处理 coverage 目录..." -ForegroundColor Yellow
Add-IgnoredFiles "^coverage/"

# .cache files/directories
Write-Host "处理 .cache 文件/目录..." -ForegroundColor Yellow
Add-IgnoredFiles "^\.cache"

# Remove duplicates
if (Test-Path $tempFile) {
    $uniqueFiles = Get-Content $tempFile | Sort-Object -Unique
    $uniqueFiles | Set-Content $tempFile
}

Write-Host ""
Write-Host "第二步：检查要移除的文件..." -ForegroundColor Cyan
Write-Host ""

# Check if there are files to remove
if (Test-Path $tempFile) {
    $fileCount = (Get-Content $tempFile | Measure-Object -Line).Lines

    if ($fileCount -gt 0) {
        Write-Host "找到 $fileCount 个文件将被从 Git 跟踪中移除（但不会删除本地文件）：" -ForegroundColor Yellow
        Write-Host "---------------------------------------------------"
        Get-Content $tempFile | ForEach-Object { Write-Host $_ }
        Write-Host "---------------------------------------------------"
        Write-Host ""

        # Ask user for confirmation
        $confirm = Read-Host "确定要移除这些文件的 Git 跟踪吗？(y/N)"

        if ($confirm -eq "y" -or $confirm -eq "Y") {
            Write-Host ""
            Write-Host "第三步：移除 Git 跟踪..." -ForegroundColor Cyan

            # Remove files from git tracking
            Get-Content $tempFile | ForEach-Object {
                $filePath = $_.Trim()
                if (-not [string]::IsNullOrWhiteSpace($filePath)) {
                    Write-Host "移除跟踪: $filePath" -ForegroundColor Green
                    git rm --cached $filePath 2>$null
                    if ($LASTEXITCODE -ne 0) {
                        Write-Host "警告：无法移除 $filePath" -ForegroundColor Yellow
                    }
                }
            }

            Write-Host ""
            Write-Host "[OK] 操作完成！已从 Git 跟踪中移除匹配 .gitignore 的文件。" -ForegroundColor Green
            Write-Host ""
            Write-Host "提示：" -ForegroundColor Cyan
            Write-Host "  - 文件仍保留在本地文件系统中"
            Write-Host "  - 运行 'git status' 查看当前状态"
            Write-Host "  - 提交更改：'git add .gitignore && git commit -m ""Add .gitignore and remove ignored files""'"
        } else {
            Write-Host "操作已取消。" -ForegroundColor Yellow
        }
    } else {
        Write-Host "没有找到需要移除的被跟踪文件。" -ForegroundColor Green
    }
} else {
    Write-Host "没有找到需要移除的被跟踪文件。" -ForegroundColor Green
}

# Clean up temp file
if (Test-Path $tempFile) {
    Remove-Item $tempFile -Force
}

Write-Host ""
Write-Host "脚本执行完成。" -ForegroundColor Green
