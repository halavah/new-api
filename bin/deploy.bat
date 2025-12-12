@echo off
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%.."
pushd "%ROOT_DIR%"

:: Get current branch name
echo Detecting current Git branch...
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "current_branch=%%i"
if "!current_branch!"=="" (
	echo Failed to detect current Git branch.
	echo Make sure you are in a Git repository.
	pause
	popd
	exit /b 1
)
echo Current branch: !current_branch!

:: Stage all changes first
echo Staging all changes...
git add .
if !errorlevel! neq 0 (
	echo Failed to stage changes.
	pause
	popd
	exit /b 1
)

:: Check if there are changes to commit
git diff --staged --quiet
if !errorlevel! equ 0 (
	echo No changes to commit.

	:: If no changes, just pull and exit
	echo Pulling latest changes from origin/!current_branch!...
	git pull origin !current_branch!
	pause
	popd
	exit /b 0
)

:: Commit changes with timestamped message
set "timestamp=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=!timestamp: =0!"
echo Committing changes with timestamp: !timestamp!...
git commit -m "!timestamp!"
if !errorlevel! neq 0 (
	echo Failed to commit changes.
	pause
	popd
	exit /b 1
)

:: Pull latest changes from the remote repository
echo Pulling latest changes from origin/!current_branch!...
git pull origin !current_branch!
if !errorlevel! neq 0 (
	echo Failed to pull changes. Resolve conflicts if any, and rerun the script.
	pause
	popd
	exit /b 1
)

:: Push changes to the repository
echo Pushing changes to origin/!current_branch!...
git push origin !current_branch!
if !errorlevel! neq 0 (
	echo Failed to push changes.
	pause
	popd
	exit /b 1
)

echo Changes successfully pulled, committed, and pushed to branch: !current_branch!
pause
popd
exit /b 0