@echo off
setlocal enabledelayedexpansion

REM Define variables
set "url=https://codeload.github.com/psfer07/Urftilities/zip/refs/tags/v1.2"
set "zipFile=%temp%\Urftilities.zip"
set "extractTo=%userprofile%\Desktop\Urftilities-1.2"
set "args="

REM Check if Urftilities is already located on the desktop
if exist "%extractTo%" (
    set /p "open=Urftilities is already located on your desktop. Do you want to open it now? (y/n) --> "
    if /i "%open%" neq "y" exit /b 0

    REM Clear the screen and present the options to the user
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
    echo 5. Open Urftilities in full mode with restart.
    echo 6. Open Urftilities in full mode silently with restart.
    choice /c 123456 /n /m "Choose an option: "

    REM Capture the choice and set arguments accordingly
    set mode=%errorlevel%
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

    REM Execute the PowerShell script with the appropriate arguments with elevated privileges
    powershell -Command "Start-Process powershell -ArgumentList '.\%extractTo%\Urftweaks.ps1 %args%' -Verb RunAs"
)

REM Create the Urftilities folder on Desktop if it doesn't exist and download/extract the ZIP file
if not exist "%extractTo%" (
    mkdir "%extractTo%"
    REM Download and extract the ZIP file using PowerShell
    powershell -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%zipFile%'"
    powershell -Command "Expand-Archive -Path '%zipFile%' -DestinationPath '%userprofile%\Desktop' -Force"
    del "%zipFile%"
)
