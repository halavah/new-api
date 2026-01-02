#!/bin/bash

# ============================================================================
# Git Ignore Cleanup & Setup Tool (Bash/macOS/Linux)
# ============================================================================
# 功能说明：
#   1. 主要功能：严格根据 .gitignore 内容移除已被 Git 跟踪的文件
#   2. 额外功能：可选升级到包含 30+ 种技术栈的完整 .gitignore 模板
#
# 支持的技术栈：
#   - 语言: Go, Java, Python, Node.js, Rust, C/C++, C#, PHP, Ruby
#   - 前端: Next.js, React, Vue.js, Angular, Svelte, Nuxt
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
#   ./clear-ignore.sh
#   或
#   bash clear-ignore.sh
#
# 注意事项：
#   - 只移除 Git 跟踪，不会删除本地文件系统中的文件
#   - 移除后需要提交更改才能生效
#   - 建议在执行前先提交当前更改
# ============================================================================

# Navigate to the directory where the script is located
cd "$(dirname "$0")"

# Go back to project root directory
cd ..

echo "=========================================="
echo "  Git Ignore 清理工具"
echo "=========================================="
echo ""

# 检查是否在 Git 仓库中
echo "检查 Git 仓库状态..."
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ 错误：当前目录不是 Git 仓库"
    exit 1
fi

echo "✅ Git 仓库检查通过"
echo ""

# Function to create comprehensive .gitignore
create_gitignore() {
    echo "📝 创建全新的 .gitignore 文件..."
    cat > .gitignore << 'GITIGNORE_EOF'
# ============================================================================
# 通用 .gitignore 模板 - 支持 20+ 种语言和框架
# 自动生成时间: $(date +%Y-%m-%d)
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
*$py.class
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
GITIGNORE_EOF

    echo "✅ .gitignore 文件创建成功！"
    echo "📦 已包含 20+ 种语言和框架的忽略规则"
    echo ""
}

# Function to append missing rules
append_missing_rules() {
    local rules_added=0

    # 定义必须包含的关键规则
    local required_rules=(
        "node_modules/"
        ".next/"
        ".wrangler/"
        "__pycache__/"
        "target/"
        ".DS_Store"
        ".env"
        "*.log"
    )

    for rule in "${required_rules[@]}"; do
        if ! grep -q "^${rule}\$" .gitignore 2>/dev/null; then
            echo "$rule" >> .gitignore
            rules_added=$((rules_added + 1))
        fi
    done

    if [ $rules_added -gt 0 ]; then
        echo "✅ 已补充 $rules_added 条缺失的核心规则"
        echo ""
    fi
}

# 检查 .gitignore 文件是否存在
if [ ! -f ".gitignore" ]; then
    echo "⚠️  未找到 .gitignore 文件，创建基础版本..."
    echo ""

    # 创建基础版本（包含核心规则）
    cat > .gitignore << 'EOF'
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
EOF

    echo "✅ 已创建基础 .gitignore 文件"
    echo ""
else
    echo "✅ 找到 .gitignore 文件"

    # 统计当前规则数量
    current_rules=$(grep -v "^#" .gitignore | grep -v "^$" | wc -l | tr -d ' ')
    echo "📊 当前包含 $current_rules 条规则"
    echo ""

    # 补充缺失的核心规则
    append_missing_rules
fi

# =============================================================================
# 主要功能：清理 Git 跟踪
# =============================================================================

echo "=========================================="
echo "开始清理 Git 跟踪的忽略文件"
echo "=========================================="
echo ""

# 临时文件存储要处理的文件
TEMP_FILES=$(mktemp)

echo "第一步：查找匹配 .gitignore 的被跟踪文件..."
echo ""

# 使用 Git 内置命令查找所有被跟踪但匹配 .gitignore 的文件
git ls-files -i -c --exclude-standard > "$TEMP_FILES" 2>/dev/null

echo "第二步：分析发现的文件..."
echo ""

# 显示将要移除的文件
if [ -s "$TEMP_FILES" ]; then
    file_count=$(wc -l < "$TEMP_FILES" | tr -d ' ')
    echo "✅ 找到 $file_count 个文件匹配 .gitignore 规则但仍被 Git 跟踪"
    echo ""
    echo "这些文件将被从 Git 跟踪中移除（但不会删除本地文件）："
    echo "---------------------------------------------------"
    cat "$TEMP_FILES"
    echo "---------------------------------------------------"
    echo ""

    # 显示文件大小统计
    total_size=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            total_size=$((total_size + size))
        fi
    done < "$TEMP_FILES"

    if [ $total_size -gt 0 ]; then
        # 转换为 MB
        size_mb=$(echo "scale=2; $total_size / 1048576" | bc 2>/dev/null || echo "0")
        echo "📊 总大小约: ${size_mb} MB"
        echo ""
    fi

    # 询问用户确认
    read -p "❓ 确定要移除这些文件的 Git 跟踪吗？(y/默认，N): " -n 1 -r
    echo
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "第三步：移除 Git 跟踪..."
        echo ""

        # 读取文件并移除跟踪
        success_count=0
        failed_count=0

        while IFS= read -r file; do
            if [ -n "$file" ]; then
                if git rm --cached -r --ignore-unmatch "$file" > /dev/null 2>&1; then
                    echo "✅ 移除跟踪: $file"
                    success_count=$((success_count + 1))
                else
                    echo "⚠️  警告：无法移除 $file"
                    failed_count=$((failed_count + 1))
                fi
            fi
        done < "$TEMP_FILES"

        echo ""
        echo "=========================================="
        echo "✅ 清理完成！"
        echo "=========================================="
        echo ""
        echo "📊 处理结果："
        echo "  - 成功移除: $success_count 个"
        if [ $failed_count -gt 0 ]; then
            echo "  - 失败: $failed_count 个"
        fi
        echo ""
        echo "📌 下一步操作："
        echo "  1. 查看状态: git status"
        echo "  2. 查看更改: git diff --cached"
        echo "  3. 提交更改: git commit -m \"chore: remove ignored files from Git tracking\""
        echo ""
        echo "💡 提示："
        echo "  - 这些文件仍保留在本地文件系统中"
        echo "  - 它们不会再被 Git 跟踪"
        echo "  - 提交后，这些文件将从远程仓库中删除（但本地保留）"

        CLEANED=true
    else
        echo "❌ 清理操作已取消"
        CLEANED=false
    fi
else
    echo "✅ 太好了！没有找到需要移除的被跟踪文件"
    echo ""
    echo "这意味着："
    echo "  - 所有被 Git 跟踪的文件都不在 .gitignore 规则中"
    echo "  - 或者 .gitignore 规则已经正确生效"
    CLEANED=false
fi

# 清理临时文件
rm -f "$TEMP_FILES"

# =============================================================================
# 可选功能：询问是否升级到完整版本
# =============================================================================

echo ""
echo "=========================================="
echo "可选：升级 .gitignore 到完整版本"
echo "=========================================="
echo ""
echo "💡 提示：完整版本包含 30+ 种技术栈（300+ 行模板）"
echo "   - Go, Java, Python, Rust, C/C++, C#, PHP, Ruby"
echo "   - Next.js, React, Vue, Angular, Svelte"
echo "   - Docker, Terraform, AWS, Kubernetes"
echo "   - 等等..."
echo ""
read -p "是否升级到完整版本？(y/默认，N): " -n 1 -r
echo
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 备份现有文件
    backup_file=".gitignore.backup.$(date +%Y%m%d_%H%M%S)"
    cp .gitignore "$backup_file"
    echo "📦 已备份现有文件到: $backup_file"
    echo ""

    # 创建完整版本
    create_gitignore
    echo "✅ 已升级到完整版本！"
    echo "💾 旧版本已备份，如需恢复请运行: mv $backup_file .gitignore"
    echo ""
else
    echo "⏭️  已跳过升级"
fi

echo ""
echo "=========================================="
echo "脚本执行完成"
echo "=========================================="
