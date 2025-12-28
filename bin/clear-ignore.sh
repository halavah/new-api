#!/bin/bash

# Navigate to the directory where the script is located
cd "$(dirname "$0")"

# Go back to project root directory
cd ..

# ignore.sh - 根据 .gitignore 内容移除已被 Git 跟踪的文件
# 适用于 macOS/Linux 系统

echo "==========================================="
echo "根据 .gitignore 内容清理 Git 跟踪文件"
echo "==========================================="

# 检查是否在 Git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "错误：当前目录不是 Git 仓库"
    exit 1
fi

# 检查 .gitignore 文件是否存在
if [ ! -f ".gitignore" ]; then
    echo "错误：未找到 .gitignore 文件"
    exit 1
fi

# 临时文件存储要处理的文件
TEMP_FILES=$(mktemp)

echo "第一步：查找被跟踪但应该被忽略的文件..."
echo ""

# 方法1: 直接处理最常见的目录模式
echo "处理 out/ 目录..."
git ls-files | grep "^out/" >> "$TEMP_FILES"

echo "处理 .next/ 目录..."
git ls-files | grep "^\\.next/" >> "$TEMP_FILES"

echo "处理 node_modules/ 目录..."
git ls-files | grep "^node_modules/" >> "$TEMP_FILES"

echo "处理 build/ 目录..."
git ls-files | grep "^build/" >> "$TEMP_FILES"

echo "处理 dist/ 目录..."
git ls-files | grep "^dist/" >> "$TEMP_FILES"

# 方法2: 处理 .gitignore 中的特定模式
echo ""
echo "处理 .gitignore 中的其他模式..."

while IFS= read -r line || [[ -n "$line" ]]; do
    # 跳过空行、注释和已经处理的目录
    if [[ -z "$line" || "$line" == \#* || "$line" == "out/" || "$line" == ".next/" || "$line" == "node_modules/" || "$line" == "build/" || "$line" == "dist/" ]]; then
        continue
    fi

    # 跳过以 ! 开头的否定模式
    if [[ "$line" == \!* ]]; then
        continue
    fi

    # 处理特定文件模式
    case "$line" in
        *.log)
            git ls-files | grep "\.log$" >> "$TEMP_FILES"
            ;;
        .env*)
            git ls-files | grep "^\\.env" >> "$TEMP_FILES"
            ;;
        *.tmp)
            git ls-files | grep "\\.tmp$" >> "$TEMP_FILES"
            ;;
        .DS_Store)
            git ls-files | grep "\\.DS_Store$" >> "$TEMP_FILES"
            ;;
        package-lock.json)
            git ls-files | grep "package-lock\\.json$" >> "$TEMP_FILES"
            ;;
        yarn.lock)
            git ls-files | grep "yarn\\.lock$" >> "$TEMP_FILES"
            ;;
        pnpm-lock.yaml)
            git ls-files | grep "pnpm-lock\\.yaml$" >> "$TEMP_FILES"
            ;;
        coverage/)
            git ls-files | grep "^coverage/" >> "$TEMP_FILES"
            ;;
        .cache)
            git ls-files | grep "^\\.cache" >> "$TEMP_FILES"
            ;;
    esac
done < .gitignore

# 去重
if [ -f "$TEMP_FILES" ]; then
    sort -u "$TEMP_FILES" > "${TEMP_FILES}.sorted"
    mv "${TEMP_FILES}.sorted" "$TEMP_FILES"
fi

echo ""
echo "第二步：检查要移除的文件..."
echo ""

# 显示将要移除的文件
if [ -s "$TEMP_FILES" ]; then
    file_count=$(wc -l < "$TEMP_FILES")
    echo "找到 $file_count 个文件将被从 Git 跟踪中移除（但不会删除本地文件）："
    echo "---------------------------------------------------"
    cat "$TEMP_FILES"
    echo "---------------------------------------------------"
    echo ""

    # 询问用户确认
    read -p "确定要移除这些文件的 Git 跟踪吗？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "第三步：移除 Git 跟踪..."

        # 使用 xargs 批量处理以提高效率
        if command -v xargs >/dev/null 2>&1; then
            xargs -I {} git rm --cached "{}" < "$TEMP_FILES"
        else
            # 如果没有 xargs，使用循环
            while IFS= read -r file; do
                if [ -n "$file" ]; then
                    echo "移除跟踪: $file"
                    git rm --cached -r "$file" 2>/dev/null || echo "警告：无法移除 $file"
                fi
            done < "$TEMP_FILES"
        fi

        echo ""
        echo "操作完成！已从 Git 跟踪中移除匹配 .gitignore 的文件。"
        echo ""
        echo "提示："
        echo "- 文件仍保留在本地文件系统中"
        echo "- 运行 'git status' 查看当前状态"
        echo "- 提交更改：'git add .gitignore && git commit -m \"Add .gitignore and remove ignored files\"'"
    else
        echo "操作已取消。"
    fi
else
    echo "没有找到需要移除的被跟踪文件。"
fi

# 清理临时文件
rm -f "$TEMP_FILES"

echo ""
echo "脚本执行完成。"