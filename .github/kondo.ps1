<#
.SYNOPSIS
    项目空间清理工具 - PowerShell 纯净版 v1.0
.DESCRIPTION
    【重要】请将此脚本文件以「UTF-8 with BOM」编码保存，以确保中文字符正确显示。
    
    此脚本使用 PowerShell 内置命令，递归地查找并删除指定的项目构建目录，
    完全无需依赖 Node.js 或 rimraf。

    功能对标 clean_projects_rm.bat v5.2。
.PARAMETER WhatIf
    添加此开关参数，将只显示将要删除的目录和计算的总大小，而不会执行任何实际的删除操作。
    这是一个安全的“演习”模式，强烈建议首次运行时使用。
    示例: .\clean_projects_ps.ps1 -WhatIf
.USAGE
    1. (可选) 在下面的“配置区域”修改要清理的目录列表。
    2. 打开 PowerShell 终端，cd 到项目根目录。
    3. 演习运行 (推荐): .\clean_projects_ps.ps1 -WhatIf
    4. 实际运行: .\clean_projects_ps.ps1
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    # 此参数会自动与 CmdletBinding 的 SupportsShouldProcess 关联，从而启用 -WhatIf 功能
)

#==============================================================================
#                              配置区域
#  请在此处添加或修改你希望清理的目录名称。
#==============================================================================
$TargetDirectories = @(
    "node_modules",
    "target"
)

#==============================================================================
#                              脚本核心逻辑 (无需修改)
#==============================================================================

# --- 初始化和欢迎信息 ---
Clear-Host
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  项目空间清理工具 (PowerShell 纯净版) v1.0" -ForegroundColor Cyan
Write-Host "================================================================"
if ($PSCmdlet.ShouldProcess("your project directories", "clean")) {
    Write-Host "ℹ️  目标根目录: $(Get-Location)" -ForegroundColor White
    Write-Host "🎯 将会查找并删除以下名称的目录: $($TargetDirectories -join ', ')" -ForegroundColor White
    Write-Host "----------------------------------------------------------------"
} else {
    Write-Host "ℹ️  演习模式 (-WhatIf): 不会执行任何实际删除操作。" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------"
}

# --- 1. 查找目标目录 ---
$dirsToDelete = @()
try {
    Write-Host "⏳ 正在快速查找目标目录..." -ForegroundColor White
    # 使用 Get-ChildItem 的 -Include 参数比 ForEach-Object 更高效
    $allDirs = Get-ChildItem -Path . -Recurse -Directory -ErrorAction SilentlyContinue
    $dirsToDelete = $allDirs | Where-Object { $_.Name -in $TargetDirectories }
}
catch {
    Write-Error "查找目录时发生错误: $_"
    exit
}

if (-not $dirsToDelete) {
    Write-Host "✅ 未找到任何需要清理的目录。您的项目空间很干净！" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    exit
}

$totalCount = $dirsToDelete.Count
Write-Host "🔍 已找到 $totalCount 个可清理的目录。" -ForegroundColor White
Write-Host ""
Write-Host "--- 将要处理以下目录 ---" -ForegroundColor Yellow
$dirsToDelete.FullName | Out-Host
Write-Host "--------------------------" -ForegroundColor Yellow
Write-Host ""

# --- 2. 计算总大小 ---
Write-Host "⏳ 正在计算总大小 (这可能需要一些时间)..." -ForegroundColor White
$totalSizeBytes = 0
$processedCount = 0
foreach ($dir in $dirsToDelete) {
    $processedCount++
    Write-Progress -Activity "计算目录大小" -Status "正在分析: $($dir.Name)" -CurrentOperation "($processedCount / $totalCount)" -PercentComplete (($processedCount / $totalCount) * 100)
    
    # 使用 Measure-Object 高效计算目录大小
    $dirSize = (Get-ChildItem -Path $dir.FullName -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $totalSizeBytes += $dirSize
}
Write-Progress -Activity "计算目录大小" -Completed

# 格式化大小显示
$sizeDisplay = ""
if ($totalSizeBytes -lt 1KB) {
    $sizeDisplay = "{0:N0} B" -f $totalSizeBytes
} elseif ($totalSizeBytes -lt 1MB) {
    $sizeDisplay = "{0:N2} KB" -f ($totalSizeBytes / 1KB)
} elseif ($totalSizeBytes -lt 1GB) {
    $sizeDisplay = "{0:N2} MB" -f ($totalSizeBytes / 1MB)
} else {
    $sizeDisplay = "{0:N2} GB" -f ($totalSizeBytes / 1GB)
}

Write-Host "💾 总计大小约为: $sizeDisplay ($('{0:N0}' -f $totalSizeBytes) 字节)" -ForegroundColor White
Write-Host ""

# --- 3. 用户确认 ---
if (-not $PSCmdlet.ShouldProcess("these $totalCount directories (Total Size: $sizeDisplay)", "Permanently Delete")) {
    Write-Host "🚫 操作已在演习模式下跳过。没有删除任何文件。" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Yellow
    exit
}

try {
    $choice = Read-Host "‼️  您确定要永久删除这 $totalCount 个目录吗? (输入 'yes' 继续)"
} catch {
    $choice = "no" # 在非交互式环境中，默认取消
}

if ($choice -ne 'yes') {
    Write-Host "🚫 操作已取消。" -ForegroundColor Red
    Write-Host "================================================================" -ForegroundColor Red
    exit
}

# --- 4. 执行删除 ---
Write-Host "🚀 开始执行清理操作..." -ForegroundColor Green
$deletedCount = 0
foreach ($dir in $dirsToDelete) {
    $deletedCount++
    $progressMessage = "[{0}/{1}] 正在删除: {2}" -f $deletedCount, $totalCount, $dir.FullName
    Write-Progress -Activity "正在清理项目" -Status $progressMessage -PercentComplete (($deletedCount / $totalCount) * 100)
    Write-Host $progressMessage

    try {
        # 使用 -LiteralPath 防止路径中的特殊字符(如[])引起问题
        Remove-Item -LiteralPath $dir.FullName -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Warning "删除 '$($dir.FullName)' 时失败: $($_.Exception.Message)"
    }
}
Write-Progress -Activity "正在清理项目" -Completed

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "✅ 所有清理任务已成功执行完毕！" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# 等待用户按键退出，以便查看结果
if ($Host.Name -eq "ConsoleHost") {
    Read-Host "按 Enter 键退出..."
}

