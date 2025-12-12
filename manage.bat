@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ========================================
REM New API - 管理脚本 (Windows)
REM ========================================

cd /d %~dp0
set BIN_DIR=%~dp0bin

REM 检查 bin 目录是否存在
if not exist "%BIN_DIR%" (
    echo [错误] bin 目录不存在: %BIN_DIR%
    pause
    exit /b 1
)

:MAIN_MENU
REM 重置 choice 变量，避免保留上次的输入
set "choice="

cls
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  New API - 管理控制台
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo ═══════════════════════════════════════════════════════════
echo   项目管理
echo ═══════════════════════════════════════════════════════════
echo.
echo   1. 🚀 启动后端     (bin\start-backend.bat)
echo.
echo   2. 🎨 启动前端     (bin\start-front.bat)
echo.
echo   3. 🚢 部署代码     (bin\deploy.bat)
echo.
echo ═══════════════════════════════════════════════════════════
echo.
echo   0. 🚪 退出
echo.
echo ═══════════════════════════════════════════════════════════
echo.

set /p choice="请选择操作 [0-3] (默认: 3): "

REM 如果用户直接按回车，默认选择 3
if "%choice%"=="" set choice=3

if "%choice%"=="1" goto START_BACKEND
if "%choice%"=="2" goto START_FRONT
if "%choice%"=="3" goto DEPLOY
if "%choice%"=="0" goto EXIT
goto INVALID

:START_BACKEND
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  执行: 启动后端
echo ╚════════════════════════════════════════════════════════════╝
echo.
call "%BIN_DIR%\start-backend.bat"
goto WAIT

:START_FRONT
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  执行: 启动前端
echo ╚════════════════════════════════════════════════════════════╝
echo.
call "%BIN_DIR%\start-front.bat"
goto WAIT

:DEPLOY
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║  执行: 部署代码
echo ╚════════════════════════════════════════════════════════════╝
echo.
call "%BIN_DIR%\deploy.bat"
goto WAIT

:INVALID
echo.
echo [错误] 无效的选项: %choice%
timeout /t 2 /nobreak >nul
goto MAIN_MENU

:WAIT
echo.
echo ═══════════════════════════════════════════════════════════
pause
goto MAIN_MENU

:EXIT
echo.
echo [信息] 感谢使用 Libra Boot Plus 管理控制台
echo.
exit /b 0
