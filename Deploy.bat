@echo off
setlocal enabledelayedexpansion

REM Define variables
set "url=https://codeload.github.com/psfer07/Urftilities/zip/refs/tags/v1.0"
set "zipFile=%temp%\Urftilities.zip"
set "extractTo=%userprofile%\Desktop"
set "args="

REM Create the Urftilities folder on Desktop
if not exist "%extractTo%" (
    mkdir "%extractTo%"
)

REM Download and extracts the ZIP file using PowerShell
powershell -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%zipFile%'"
powershell -Command "Expand-Archive -Path '%zipFile%' -DestinationPath '%extractTo%' -Force"
del "%zipFile%"

set /p open=Urftilities has been downloaded and extracted to your desktop! Do you want to execute it? (y/n)
if /i "%open%" neq "y" exit /b 0
cls
echo Choose a number to execute Urftilities...
echo 1. Open Urftilities in regular mode (it just cleans temporary files)
echo 2. Open Urftilities in full mode (execute all the available optimizations)
echo ---------------------------------------------------------------------------
echo ------------------------------  Silent mode  ------------------------------
echo ---------------------------------------------------------------------------
echo 3. Open Urftilities silently in regular mode (no prompts)
echo 4. Open Urftilities silently in full mode (no prompts)
echo ---------------------------------------------------------------------------
echo ------------------------------  Restart mode  -----------------------------
echo ---------------------------------------------------------------------------
echo 5. Open Urftilities in full mode
echo 6. Open Urftilities in full mode silently
choice /c 123456 /n /m ""
if %errorlevel%==6 set "args=-full -silent -restart"
if %errorlevel%==5 set "args=-full -restart"
if %errorlevel%==4 set "args=-full -silent"
if %errorlevel%==3 set "args=-silent"
if %errorlevel%==2 set "args=-full"
if %errorlevel%==1 set "args="
powershell -Command "%extractTo%\Urftilities-1.0\Urftweaks.ps1 %args%"