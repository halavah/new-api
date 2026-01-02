#!/usr/bin/env pwsh

# ============================================================================
# Git Ignore Cleanup & Setup Tool (PowerShell)
# ============================================================================
# 功能说明：
#   1. 主要功能：严格根据 .gitignore 内容移除已被 Git 跟踪的文件
#   2. 额外功能：可选升级到包含 30+ 种技术栈的完整 .gitignore 模板
#
# 支持的技术栈：
#   - 语言: Go, Java, Python, Node.js, Rust, C/C++, C#, PHP, Ruby
#   - 前端: Next.js, React, Vue, Angular, Svelte, Nuxt
#   - 云服务: Wrangler, Vercel, Docker, Terraform, AWS
#   - 数据库: SQLite, PostgreSQL, MySQL
#   - 编辑器: VS Code, JetBrains, Vim, Sublime
#   - 系统: macOS, Windows, Linux
#
# 工作流程：
#   1. 检查是否在 Git 仓库中
#   2. 检查或创建 .gitignore 文件
#   3. 【主要功能】使用 Git 内置功能查找并清理应该被忽略但被跟踪的文件
#   4. 【可选功能】询问是否升级到完整版本 .gitignore
#
# 运行方式：
#   .\clear-ignore.ps1
#   或
#   pwsh clear-ignore.ps1
#
# 注意事项：
#   - 只移除 Git 跟踪，不会删除本地文件系统中的文件
#   - 移除后需要提交更改才能生效
#   - 建议在执行前先提交当前更改
# ============================================================================

# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Git Ignore 清理工具" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project root
Set-Location "$PSScriptRoot\.."

# Check if in a Git repository
Write-Host "检查 Git 仓库状态..." -ForegroundColor Yellow
$gitDir = git rev-parse --git-dir 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 错误：当前目录不是 Git 仓库" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit 1
}

Write-Host "✅ Git 仓库检查通过" -ForegroundColor Green
Write-Host ""

# Function to create comprehensive .gitignore
function New-GitIgnore {
    Write-Host "📝 创建全新的 .gitignore 文件..." -ForegroundColor Yellow

    $gitignoreContent = @"
# ============================================================================
# 通用 .gitignore 模板 - 支持 20+ 种语言和框架
# 自动生成时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# ============================================================================

# ===== 通用规则 =====
# 环境变量
.env
.env.local
.env.*.local
.env.development
.env.production

# 日志文件
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# 临时文件
*.tmp
*.temp
tmp/
temp/

# 备份文件
*.bak
*.backup
*~

# ===== Node.js & JavaScript =====
node_modules/
npm-debug.log
yarn-error.log
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions
package-lock.json
yarn.lock
pnpm-lock.yaml

# ===== Next.js =====
.next/
out/
.vercel
*.tsbuildinfo
next-env.d.ts

# ===== React =====
build/
.cache/

# ===== Vue.js =====
dist/
.nuxt/
.output/

# ===== Angular =====
.angular/
/dist
/tmp
/out-tsc
/bazel-out

# ===== Svelte =====
.svelte-kit/
package/

# ===== TypeScript =====
*.tsbuildinfo

# ===== Cloudflare Wrangler =====
.wrangler/
.dev.vars
wrangler.toml.local

# ===== Python =====
__pycache__/
*.py[cod]
*`$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
venv/
ENV/
env/
.venv
pip-log.txt
pip-delete-this-directory.txt
.pytest_cache/
.coverage
htmlcov/
.tox/
.hypothesis/

# ===== Go =====
# Binaries
*.exe
*.exe~
*.dll
*.so
*.dylib
# Test binary
*.test
# Output of go build
*.out
# Dependency directories
vendor/
go.sum

# ===== Java =====
*.class
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar
target/
build/
.gradle/
.mvn/
!.mvn/wrapper/maven-wrapper.jar
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties

# ===== Rust =====
target/
Cargo.lock
**/*.rs.bk

# ===== C/C++ =====
*.o
*.out
*.obj
*.exe
*.dll
*.so
*.dylib
*.a
*.lib
*.app
CMakeFiles/
CMakeCache.txt
cmake_install.cmake
Makefile

# ===== C# / .NET =====
bin/
obj/
*.dll
*.exe
*.pdb
*.user
*.suo
*.cache
.vs/
*.nupkg
*.snupkg

# ===== PHP =====
vendor/
composer.lock
composer.phar

# ===== Ruby / Rails =====
*.gem
*.rbc
/.config
/coverage/
/InstalledFiles
/pkg/
/spec/reports/
/test/tmp/
/test/version_tmp/
/tmp/
.bundle/
vendor/bundle

# ===== Terraform =====
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
.terraform.lock.hcl

# ===== Docker =====
*.log
Dockerfile.local
docker-compose.override.yml

# ===== AWS =====
.aws-sam/

# ===== Vercel =====
.vercel

# ===== 数据库 =====
*.db
*.sqlite
*.sqlite3
*.sql

# ===== VS Code =====
.vscode/
*.code-workspace
.history/

# ===== JetBrains IDEs (IntelliJ, WebStorm, PyCharm, etc.) =====
.idea/
*.iml
*.iws
*.ipr
out/

# ===== Vim =====
*.swp
*.swo
*~
.*.sw[a-p]

# ===== Sublime Text =====
*.sublime-project
*.sublime-workspace

# ===== macOS =====
.DS_Store
.AppleDouble
.LSOverride
._*

# ===== Windows =====
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
*.stackdump
[Dd]esktop.ini

# ===== Linux =====
*~
.directory
.fuse_hidden*
.Trash-*
.nfs*

# ===== 测试覆盖率 =====
coverage/
.nyc_output/
*.lcov

# ============================================================================
# 项目特定规则（如有需要，请在下方添加）
# ============================================================================
"@

    $gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
    Write-Host "✅ .gitignore 文件创建成功！" -ForegroundColor Green
    Write-Host "📦 已包含 20+ 种语言和框架的忽略规则" -ForegroundColor Cyan
    Write-Host ""
}

# Function to append missing rules
function Add-MissingRules {
    $rulesAdded = 0

    # 定义必须包含的关键规则
    $requiredRules = @(
        "node_modules/",
        ".next/",
        ".wrangler/",
        "__pycache__/",
        "target/",
        ".DS_Store",
        ".env",
        "*.log"
    )

    $gitignoreContent = Get-Content ".gitignore" -ErrorAction SilentlyContinue

    foreach ($rule in $requiredRules) {
        $escapedRule = [regex]::Escape($rule)
        if (-not ($gitignoreContent -match "^$escapedRule$")) {
            Add-Content -Path ".gitignore" -Value $rule
            $rulesAdded++
        }
    }

    if ($rulesAdded -gt 0) {
        Write-Host "✅ 已补充 $rulesAdded 条缺失的核心规则" -ForegroundColor Green
        Write-Host ""
    }
}

# 检查 .gitignore 文件是否存在
if (-not (Test-Path ".gitignore")) {
    Write-Host "⚠️  未找到 .gitignore 文件，创建基础版本..." -ForegroundColor Yellow
    Write-Host ""

    # 创建基础版本
    $basicGitignore = @"
# Node.js
node_modules/
*.log

# Environment
.env
.env.local

# Cloudflare
.wrangler/

# Build outputs
.next/
build/
dist/

# Python
__pycache__/
*.pyc

# Rust/Go
target/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
"@

    $basicGitignore | Out-File -FilePath ".gitignore" -Encoding UTF8
    Write-Host "✅ 已创建基础 .gitignore 文件" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "✅ 找到 .gitignore 文件" -ForegroundColor Green

    # 统计当前规则数量
    $currentRules = (Get-Content ".gitignore" | Where-Object { $_ -notmatch "^#" -and $_ -notmatch "^\s*$" }).Count
    Write-Host "📊 当前包含 $currentRules 条规则" -ForegroundColor Cyan
    Write-Host ""

    # 补充缺失的核心规则
    Add-MissingRules
}

# =============================================================================
# 主要功能：清理 Git 跟踪
# =============================================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "开始清理 Git 跟踪的忽略文件" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Create temp file path
$tempFile = Join-Path $env:TEMP "git_ignore_files.txt"

# Clear temp file if exists
if (Test-Path $tempFile) {
    Remove-Item $tempFile -Force
}

Write-Host "第一步：查找匹配 .gitignore 的被跟踪文件..." -ForegroundColor Yellow
Write-Host ""

# 使用 Git 内置命令查找所有被跟踪但匹配 .gitignore 的文件
git ls-files -i -c --exclude-standard 2>$null | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "第二步：分析发现的文件..." -ForegroundColor Yellow
Write-Host ""

# Check if there are files to remove
$cleaned = $false
if ((Test-Path $tempFile) -and (Get-Content $tempFile -ErrorAction SilentlyContinue).Length -gt 0) {
    $files = Get-Content $tempFile | Where-Object { $_.Trim() -ne "" }
    $fileCount = $files.Count

    if ($fileCount -gt 0) {
        Write-Host "✅ 找到 $fileCount 个文件匹配 .gitignore 规则但仍被 Git 跟踪" -ForegroundColor Green
        Write-Host ""
        Write-Host "这些文件将被从 Git 跟踪中移除（但不会删除本地文件）：" -ForegroundColor Yellow
        Write-Host "---------------------------------------------------"
        $files | ForEach-Object { Write-Host $_ }
        Write-Host "---------------------------------------------------"
        Write-Host ""

        # 计算文件总大小
        $totalSize = 0
        foreach ($file in $files) {
            if (Test-Path $file) {
                $totalSize += (Get-Item $file).Length
            }
        }

        if ($totalSize -gt 0) {
            $sizeMB = [math]::Round($totalSize / 1MB, 2)
            Write-Host "📊 总大小约: $sizeMB MB" -ForegroundColor Cyan
            Write-Host ""
        }

        # Ask user for confirmation
        $confirm = Read-Host "❓ 确定要移除这些文件的 Git 跟踪吗？(y/默认，N)"
        Write-Host ""

        if ($confirm -eq "y" -or $confirm -eq "Y") {
            Write-Host "第三步：移除 Git 跟踪..." -ForegroundColor Yellow
            Write-Host ""

            $successCount = 0
            $failedCount = 0

            # Remove files from git tracking
            foreach ($file in $files) {
                $filePath = $file.Trim()
                if (-not [string]::IsNullOrWhiteSpace($filePath)) {
                    git rm --cached -r --ignore-unmatch $filePath 2>$null | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "✅ 移除跟踪: $filePath" -ForegroundColor Green
                        $successCount++
                    } else {
                        Write-Host "⚠️  警告：无法移除 $filePath" -ForegroundColor Yellow
                        $failedCount++
                    }
                }
            }

            Write-Host ""
            Write-Host "==========================================" -ForegroundColor Cyan
            Write-Host "✅ 清理完成！" -ForegroundColor Green
            Write-Host "==========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "📊 处理结果：" -ForegroundColor Cyan
            Write-Host "  - 成功移除: $successCount 个" -ForegroundColor Green
            if ($failedCount -gt 0) {
                Write-Host "  - 失败: $failedCount 个" -ForegroundColor Yellow
            }
            Write-Host ""
            Write-Host "📌 下一步操作：" -ForegroundColor Cyan
            Write-Host "  1. 查看状态: git status"
            Write-Host "  2. 查看更改: git diff --cached"
            Write-Host "  3. 提交更改: git commit -m `"chore: remove ignored files from Git tracking`""
            Write-Host ""
            Write-Host "💡 提示：" -ForegroundColor Cyan
            Write-Host "  - 这些文件仍保留在本地文件系统中"
            Write-Host "  - 它们不会再被 Git 跟踪"
            Write-Host "  - 提交后，这些文件将从远程仓库中删除（但本地保留）"

            $cleaned = $true
        } else {
            Write-Host "❌ 清理操作已取消" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✅ 太好了！没有找到需要移除的被跟踪文件" -ForegroundColor Green
        Write-Host ""
        Write-Host "这意味着：" -ForegroundColor Cyan
        Write-Host "  - 所有被 Git 跟踪的文件都不在 .gitignore 规则中"
        Write-Host "  - 或者 .gitignore 规则已经正确生效"
    }
} else {
    Write-Host "✅ 太好了！没有找到需要移除的被跟踪文件" -ForegroundColor Green
    Write-Host ""
    Write-Host "这意味着：" -ForegroundColor Cyan
    Write-Host "  - 所有被 Git 跟踪的文件都不在 .gitignore 规则中"
    Write-Host "  - 或者 .gitignore 规则已经正确生效"
}

# Clean up temp file
if (Test-Path $tempFile) {
    Remove-Item $tempFile -Force
}

# =============================================================================
# 可选功能：询问是否升级到完整版本
# =============================================================================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "可选：升级 .gitignore 到完整版本" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 提示：完整版本包含 30+ 种技术栈（300+ 行模板）" -ForegroundColor Cyan
Write-Host "   - Go, Java, Python, Rust, C/C++, C#, PHP, Ruby"
Write-Host "   - Next.js, React, Vue, Angular, Svelte"
Write-Host "   - Docker, Terraform, AWS, Kubernetes"
Write-Host "   - 等等..."
Write-Host ""
$confirm = Read-Host "是否升级到完整版本？(y/默认，N)"
Write-Host ""

if ($confirm -eq "y" -or $confirm -eq "Y") {
    # 备份现有文件
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = ".gitignore.backup.$timestamp"
    Copy-Item ".gitignore" -Destination $backupFile
    Write-Host "📦 已备份现有文件到: $backupFile" -ForegroundColor Green
    Write-Host ""

    # 创建完整版本
    New-GitIgnore
    Write-Host "✅ 已升级到完整版本！" -ForegroundColor Green
    Write-Host "💾 旧版本已备份，如需恢复请运行: Move-Item $backupFile .gitignore -Force" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "⏭️  已跳过升级" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "脚本执行完成" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
