@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "WSL_SCRIPT=%SCRIPT_DIR:\=/%submit.sh"

where bash >nul 2>nul
if %errorlevel%==0 (
  bash "%SCRIPT_DIR%submit.sh" %*
  exit /b %errorlevel%
)

if exist "%ProgramFiles%\Git\bin\bash.exe" (
  "%ProgramFiles%\Git\bin\bash.exe" "%SCRIPT_DIR%submit.sh" %*
  exit /b %errorlevel%
)

where wsl >nul 2>nul
if %errorlevel%==0 (
  wsl bash "%WSL_SCRIPT%" %*
  exit /b %errorlevel%
)

echo Error: could not find bash or wsl to run submit.sh.
exit /b 1
