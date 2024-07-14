# This script will apply MarkC's mouse acceleration fix (for 100% DPI)
# Modified by psfer07

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit 1
}

Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\edit-regs.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Improving performance"
Write-Host "--> Optimizing Windows interface..."

# Apply MarkC's mouse acceleration fix
Write-Host `n"Improving mouse response..."
Set-RegistryItem -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity", "MouseHoverTime" -Value 10
Set-RegistryItem -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity", "MouseSpeed", "MouseThreshold1", "MouseThreshold2" -Value 0
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" "SmoothMouseXCurve" -Value ([byte[]](0x00, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, 0xC0, 0xCC, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x00,
                0x80, 0x99, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x66, 0x26, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x33, 0x33, 0x00, 0x00, 0x00, 0x00, 0x00))
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" "SmoothMouseYCurve" -Value ([byte[]](0x00, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00,
                0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xA8, 0x00, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0x00, 0x00))

# Disable mouse pointer hiding
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x9e, 0x1e, 0x06, 0x80, 0x12, 0x00, 0x00, 0x00))

# Setting folder view options
Write-Host "Done!"
Write-Host `n"Enabling deatiled view on Windows Explorer..."
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt", "HideDrivesWithNoMedia", "ShowSyncProviderNotifications", "ShowTaskViewButton", "PeopleBand" 0
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1

# Optimize explorer visuals
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking", "LaunchTo" -Value 1

Write-Host "Done!"
Write-Host `n"Removing annoying features from the Windows UI..."
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "EnableFeeds", "ShellFeedsTaskbarViewMode" -Value 0, 2
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "ShellFeedsTaskbarOpenOnHover" -Value 0
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Value 1
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Value 1

# Remove 3D Objects from This PC
Write-Host "Done!"
Write-Host `n"Removing unwanted folders..."
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -ErrorAction SilentlyContinue
Write-Host "Done!"
