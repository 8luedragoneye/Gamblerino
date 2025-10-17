@echo off
echo ========================================
echo Git Push Script for Cardy Project
echo ========================================
echo.

echo Checking git status...
git status --porcelain

echo.
echo Adding all changes...
git add -A

echo.
set /p commitMessage="Enter commit message: "
if "%commitMessage%"=="" (
    echo No message provided, using default...
    set commitMessage="Update project files and structure - %date% %time%"
)

echo Committing changes with message: %commitMessage%
git commit -m "%commitMessage%"

echo.
echo Pushing to remote repository...
git push

echo.
echo ========================================
echo Git push completed!
echo ========================================
pause