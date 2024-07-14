@echo off
setlocal enabledelayedexpansion

REM Define variables
set "url=https://codeload.github.com/psfer07/Urftilities/zip/refs/tags/v1.0"
set "zipFile=%temp%\Urftilities.zip"
set "extractTo=%userprofile%\Desktop"
set "args="

if exist "%extractTo%" (
    set /p "open=Urftilities is already located in your desktop. Do you want open it now? (y/n)"
)

REM Create the Urftilities folder on Desktop
if not exist "%extractTo%" (
    mkdir "%extractTo%"
    REM Download and extracts the ZIP file using PowerShell
    powershell -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%zipFile%'"
    powershell -Command "Expand-Archive -Path '%zipFile%' -DestinationPath '%extractTo%' -Force"
    del "%zipFile%"
    set /p open=Urftilities has been downloaded and extracted to your desktop. Do you want to execute it? (y/n)
)

if /i "%open%" neq "y" exit /b 0
cls
echo Choose a number to execute Urftilities...
echo 1. Open Urftilities in regular mode (it just cleans temporary files).
echo 2. Open Urftilities in full mode (execute all the available optimizations).
echo ---------------------------------------------------------------------------
echo ------------------------------  Silent mode  ------------------------------
echo ---------------------------------------------------------------------------
echo 3. Open Urftilities silently in regular mode (no prompts).
echo 4. Open Urftilities silently in full mode (no prompts).
echo ---------------------------------------------------------------------------
echo ------------------------------  Restart mode  -----------------------------
echo ---------------------------------------------------------------------------
echo 5. Open Urftilities in full mode.
echo 6. Open Urftilities in full mode silently.
choice /c 123456 /n /m ""
set mode=%errorlevel%

:: Determine the arguments based on the mode selected
if %mode%==6 (
    set args=-full -silent -restart
) else if %mode%==5 (
    set args=-full -restart
) else if %mode%==4 (
    set args=-full -silent
) else if %mode%==3 (
    set args=-normal -silent
) else if %mode%==2 (
    set args=-full
) else if %mode%==1 (
    set args=-normal
)
powershell -Command "%extractTo%\Urftilities-1.0\Urftweaks.ps1 %args%"