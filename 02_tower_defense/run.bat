@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "GAME_DIR=%SCRIPT_DIR%src"
set "LOCAL_WIN_LOVE=%SCRIPT_DIR%..\love-11.5-win64\lovec.exe"

if defined LOVE_BIN (
    goto :run
)

if exist "%LOCAL_WIN_LOVE%" (
    set "LOVE_BIN=%LOCAL_WIN_LOVE%"
    goto :run
)

where love >nul 2>&1
if %errorlevel%==0 (
    set "LOVE_BIN=love"
    goto :run
)

echo LOVE2D executable not found.
echo - Try: set LOVE_BIN=C:\path\to\love.exe ^& run.bat
echo - Or run VS Code task: Love2D: Run Tower Defense
exit /b 1

:run
"%LOVE_BIN%" "%GAME_DIR%"
