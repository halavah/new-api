#!/bin/bash

# ============================================================================
# Git Deploy Tool (自动提交推送 - Bash)
# ============================================================================
# 功能说明：
#   自动执行 git 工作流：暂存 -> 提交 -> 拉取 -> 推送
#
# 工作流程：
#   1. 检测当前分支
#   2. 暂存所有更改（git add .）
#   3. 检查是否有更改需要提交
#      - 有更改：使用时间戳提交 -> 拉取 -> 推送
#      - 无更改：仅拉取
#   4. 自动处理远程更新
#
# 强制同步逻辑（当 git pull 失败时自动触发）：
#   ⚠️  检测到 Pull 失败 → 判断为远程历史可能被截断/重写
#   🔄 自动强制同步流程（在后台进程中执行）：
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
#   ./deploy.sh
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
#   ⚠️  强制同步会完全覆盖本地更改和未跟踪文件
#   ⚠️  触发强制同步时，本地未提交的更改将会丢失
#   💡 如需保留本地更改，请在运行前先提交或备份
# ============================================================================

# Function to safely pull with fallback to force reset
safe_pull() {
    local branch=$1

    echo "Pulling latest changes from origin/$branch..."
    git pull origin "$branch"

    if [ $? -ne 0 ]; then
        echo ""
        echo "⚠️  Pull failed. Detected possible history divergence."
        echo "🔄 Initiating detached force sync..."
        echo "The script will now close to allow safe file overwrites."
        echo ""

        # Get the parent directory of the project root (to avoid script being deleted)
        # Script is at: PROJECT_ROOT/.github/deploy.sh
        # $(dirname "$0") is PROJECT_ROOT/.github
        # Parent is PROJECT_ROOT
        # Parent of PROJECT_ROOT is where we want to start
        project_root=$(cd "$(dirname "$0")/.." && pwd)
        parent_dir=$(dirname "$project_root")
        project_dir_name=$(basename "$project_root")

        # Construct the cleanup command to run detached from parent directory
        # This avoids the script being deleted while running
        # Use nohup to ensure the process continues even if parent exits
        (
            cd "$parent_dir" && \
            echo "Changed to parent directory: $parent_dir" && \
            echo "Waiting for parent process to exit..." && \
            sleep 1 && \
            echo "🔄 Force Syncing in detached process..." && \
            cd "$project_dir_name" && \
            git fetch origin && \
            if [ $? -eq 0 ]; then
                git reset --hard "origin/$branch" && \
                git clean -fd && \
                echo "✅ Sync Complete! You can close this terminal." || \
                echo "❌ Reset or clean failed."
            else
                echo "❌ Fetch failed."
            fi
        ) > /dev/null 2>&1 &

        # Exit immediately to release file handles/execution lock
        exit 0
    fi

    return 0
}

# Navigate to project root (one level up from script directory)
cd "$(dirname "$0")/.."

# Get current branch name
echo "Detecting current Git branch..."
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -z "$current_branch" ]; then
    echo "Failed to detect current Git branch."
    echo "Make sure you are in a Git repository."
    exit 1
fi
echo "Current branch: $current_branch"

# Stage all changes first
echo "Staging all changes..."
git add .
if [ $? -ne 0 ]; then
    echo "Failed to stage changes."
    exit 1
fi

# Check if there are changes to commit
git diff --staged --quiet
if [ $? -eq 0 ]; then
    echo "No changes to commit."

    # If no changes, just pull and exit
    safe_pull "$current_branch"
    exit $?
fi

# Commit changes with timestamped message
timestamp=$(date +"%Y%m%d_%H%M%S")
echo "Committing changes with timestamp: $timestamp..."
git commit -m "$timestamp"
if [ $? -ne 0 ]; then
    echo "Failed to commit changes."
    exit 1
fi

# Pull latest changes from the remote repository
safe_pull "$current_branch"
if [ $? -ne 0 ]; then
    echo "Failed to sync with remote."
    exit 1
fi

# Push changes to the repository
echo "Pushing changes to origin/$current_branch..."
git push origin "$current_branch"
if [ $? -ne 0 ]; then
    echo "Failed to push changes."
    exit 1
fi

echo "Changes successfully pulled, committed, and pushed to branch: $current_branch"
exit 0
