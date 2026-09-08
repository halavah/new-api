#!/bin/sh
#
# clean_projects_rm.sh
# 版本: 4.1 (POSIX sh 兼容最终版)
# 作者: 维格数智
# 描述: 使用 rm -rf 命令安全地清理项目构建目录。此版本完全兼容 POSIX sh,
#      解决了 bash 特有语法 (如 mapfile, < <(...) ) 导致的兼容性问题。
#
# -------------------- 清理目标目录列表 --------------------
#   - target/ (Maven / Cargo / SBT)
#   - node_modules/ (Node.js / JavaScript)
#   - build/ (Gradle / CMake / etc.)
# -----------------------------------------------------------------

# --- 配置区域 ---
# // 清理的目标目录名列表 (用于界面显示)
TARGET_DIRS_DISPLAY="node_modules, target"

# --- 脚本核心逻辑 (无需修改) ---

# // 当任何命令失败时立即退出脚本
set -e

# // 函数：检查依赖命令是否存在
check_deps() {
  if ! command -v pv >/dev/null 2>&1; then
    echo "❌ 错误: 核心依赖 'pv' 命令未找到。"
    echo "   此工具需要 pv 来显示进度条。"
    echo "   请根据你的操作系统安装它:"
    echo "     - macOS (Homebrew): brew install pv"
    echo "     - Debian/Ubuntu:    sudo apt-get install pv"
    echo "     - CentOS/RHEL:      sudo yum install pv"
    exit 1
  fi
}

# // 主函数
main() {
  check_deps

  echo ""
  echo "================================================================"
  echo " 项目空间清理工具 (POSIX sh 兼容版) v4.1 "
  echo "================================================================"
  echo "ℹ️  目标根目录: $(pwd)"
  echo "🎯 将会查找并删除以下名称的目录: $TARGET_DIRS_DISPLAY"
  echo "----------------------------------------------------------------"

  echo "⏳ 正在查找目标目录，请稍候..."
  # // [兼容性修复] 使用 POSIX sh 兼容的方式查找目录。
  # // 将结果存储在一个换行符分隔的字符串变量中。
  # // find 的 -o 表示“或”条件。-prune 选项可以避免深入到找到的目录中，提高效率。
  DIRS_TO_DELETE=$(find . -type d \( -name "node_modules" -o -name "target" \) -prune)

  # // 检查是否找到任何目录
  if [ -z "$DIRS_TO_DELETE" ]; then
    echo "✅ 未找到任何需要清理的目录。您的项目空间很干净！"
    echo "================================================================"
    echo ""
    exit 0
  fi

  # // [兼容性修复] 使用 POSIX sh 兼容的方式计算行数
  total_count=$(echo "$DIRS_TO_DELETE" | grep -c .)

  echo "🔍 已找到 $total_count 个可清理的目录。"
  echo ""
  echo "--- 将要删除以下目录 ---"
  echo "$DIRS_TO_DELETE"
  echo "--------------------------"

  echo "⏳ 正在计算总大小..."
  # // [兼容性修复] 使用 POSIX sh 兼容的方式计算总大小
  # // 使用 echo 和管道将目录列表传递给 xargs，再由 du 计算
  total_size=$(echo "$DIRS_TO_DELETE" | xargs du -shc 2>/dev/null | tail -n 1 | awk '{print $1}')
  echo "💾 总计大小约为: $total_size"
  echo ""

  # // [兼容性修复] 使用 POSIX sh 兼容的 read 语法
  printf "‼️  您确定要永久删除这 %s 个目录吗? (输入 'yes' 继续): " "$total_count"
  read -r choice
  if [ "$choice" != "yes" ]; then
    echo "🚫 操作已取消。"
    echo "================================================================"
    echo ""
    exit 0
  fi

  echo "🚀 开始执行清理操作..."

  # // 核心删除逻辑：
  # // 使用 echo 将目录列表通过管道传给 pv 和 xargs
  # // pv 的 -l 表示按行计数，-s 设置进度条总数
  echo "$DIRS_TO_DELETE" | \
  pv -l -s "$total_count" -N "清理进度" | \
  xargs rm -rf

  echo ""
  echo "================================================================"
  echo "✅ 所有清理任务已成功执行完毕！"
  echo "================================================================"
  echo ""
}

# // 执行主程序入口
main

