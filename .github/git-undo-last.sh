#!/bin/bash
# ========================================================================
# git-undo-last.sh - 撤销最后一次提交
# ========================================================================
# 功能说明：
#   撤销当前仓库的最后一次提交，保留更改在工作区
#
# 操作说明：
#   使用 git reset --soft HEAD~ 撤销最后一次提交
#   提交的更改会保留在工作区，可以重新修改后再次提交
#
# 安全特性：
#   - 执行前会显示最后一次提交的信息
#   - 需要用户确认后才执行撤销
#   - 仅撤销提交，不删除任何代码更改
#
# 使用场景：
#   - 提交信息写错了
#   - 提交时漏掉了某些文件
#   - 需要修改最后一次提交的内容
#   - 想要合并多次提交
#
# 运行方式：
#   ./git-undo-last.sh
#   或在项目根目录运行
#
# 注意事项：
#   [WARN] 仅撤销最后一次提交，不会删除代码
#   [WARN] 如果已经推送到远程，撤销后需要强制推送
#   [WARN] 建议在未推送前使用此命令
#   [TIP] 如果需要完全删除提交（包括更改），使用 git reset --hard HEAD~1
# ========================================================================

# 检查是否是 Git 仓库
if [ ! -d ".git" ]; then
    echo ""
    echo -e "\033[31m[FAIL] 错误: 当前目录不是 Git 仓库\033[0m"
    echo ""
    read -p "按回车键退出..."
    exit 1
fi

current_dir=$(pwd)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  撤销最后一次提交"
echo "  当前仓库: $current_dir"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 获取最后一次提交信息
last_commit=$(git log -1 --pretty=format:"%H|%an|%ae|%ai|%s" 2>/dev/null)

if [ -z "$last_commit" ]; then
    echo -e "\033[31m[FAIL] 错误: 无法获取提交信息，仓库可能没有任何提交\033[0m"
    echo ""
    read -p "按回车键退出..."
    exit 1
fi

# 解析提交信息
commit_hash=$(echo "$last_commit" | cut -d'|' -f1)
author_name=$(echo "$last_commit" | cut -d'|' -f2)
author_email=$(echo "$last_commit" | cut -d'|' -f3)
commit_date=$(echo "$last_commit" | cut -d'|' -f4)
commit_message=$(echo "$last_commit" | cut -d'|' -f5-)

# 显示最后一次提交信息
echo "[NOTE] 最后一次提交信息:"
echo ""
echo "  提交哈希: \033[33m${commit_hash}\033[0m"
echo "  作者: ${author_name} <${author_email}>"
echo "  提交时间: ${commit_date}"
echo "  提交信息: ${commit_message}"
echo ""

# 获取当前分支
current_branch=$(git branch --show-current)
echo " 当前分支: \033[36m${current_branch}\033[0m"
echo ""

# 检查是否有未推送的提交
unpushed_commits=$(git log @{u}..HEAD 2>/dev/null)
if [ -n "$unpushed_commits" ]; then
    echo -e "\033[33m[WARN]  警告: 本地有未推送的提交\033[0m"
    unpushed_count=$(echo "$unpushed_commits" | grep -c "^commit " || echo "0")
    echo "   未推送提交数: \033[33m${unpushed_count} 个\033[0m"
    echo ""
fi

# 获取当前状态
status_output=$(git status --porcelain 2>/dev/null)
echo "[STAT] 当前状态:"
if [ -n "$status_output" ]; then
    changed_files=$(echo "$status_output" | wc -l | tr -d ' ')
    echo -e "   \033[33m有未提交的更改: ${changed_files} 个文件\033[0m"
else
    echo -e "   \033[32m工作区干净\033[0m"
fi
echo ""

# 警告提示
echo -e "\033[33m[WARN]  操作说明:\033[0m"
echo "   此操作将撤销最后一次提交，但保留所有更改在工作区"
echo "   你可以修改后重新提交"
echo ""

# 询问确认
read -p "❓ 确认要撤销最后一次提交吗？(y/n) " confirmation

if [ "$confirmation" = "y" ] || [ "$confirmation" = "Y" ] || [ "$confirmation" = "yes" ]; then
    echo ""
    echo "[SYNC] 正在撤销提交..."

    # 使用 --soft 保留更改在工作区
    if git reset --soft HEAD~1 2>/dev/null; then
        echo ""
        echo -e "\033[32m[OK] 成功撤销最后一次提交\033[0m"
        echo ""
        echo "[NOTE] 撤销后的状态:"

        # 显示撤销后的状态
        new_status_output=$(git status --porcelain 2>/dev/null)
        if [ -n "$new_status_output" ]; then
            changed_files=$(echo "$new_status_output" | wc -l | tr -d ' ')
            echo -e "   \033[32m已暂存的文件: ${changed_files} 个\033[0m"

            # 列出已暂存的文件
            echo ""
            echo "    已暂存的文件列表:"
            echo "$new_status_output" | while IFS= read -r line; do
                status_char="${line:0:1}"
                file_path="${line:3}"

                case "$status_char" in
                    M) file_status="已修改" ;;
                    A) file_status="已添加" ;;
                    D) file_status="已删除" ;;
                    R) file_status="已重命名" ;;
                    *) file_status="未知" ;;
                esac

                echo "     ${file_status}: ${file_path}"
            done
        fi

        echo ""
        echo -e "\033[36m[TIP] 提示: 使用 'git commit' 重新提交这些更改\033[0m"
        echo ""
    else
        echo ""
        echo -e "\033[31m[FAIL] 错误: 撤销提交失败\033[0m"
        echo ""
    fi
else
    echo ""
    echo -e "\033[31m[FAIL] 操作已取消\033[0m"
    echo ""
fi

read -p "按回车键退出..."
exit 0
