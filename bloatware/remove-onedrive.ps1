### Original script from: https://github.com/W4RH4WK/Debloat-Windows-10
### This script will remove and disable OneDrive integration. ###
# Optimized by psfer07

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}

Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\edit-regs.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Removing bloatware"
Write-Host "Removing OneDrive..."

Write-Host `n"Saving your files before doing anything..."
Start-Process -FilePath powershell -ArgumentList "robocopy ''$($env:USERPROFILE.TrimEnd())\\OneDrive'' ''$($env:USERPROFILE.TrimEnd())\\'' /e /xj" -Wait -ErrorAction SilentlyContinue | Out-Null
Write-Host "Done!"


Write-Host `n"Stopping processes (don't panic)..."
$services = @("explorer.exe", "OneDrive.exe")
foreach ($service in $services) { Start-Process taskkill.exe -ArgumentList "/f /im $service" -Wait -ErrorAction SilentlyContinue | Out-Null }
Write-Host "Done!"

Write-Host `n"Executing OneDrive uninstallers..."
if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
}
Write-Host "Done!"

Write-Host `n"Removing OneDrive installations leftovers..."
Remove-Item -Path "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -ErrorAction SilentlyContinue
Remove-Item -Path "$env:localappdata\Microsoft\OneDrive" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:programdata\Microsoft OneDrive" -Recurse -ErrorAction SilentlyContinue 
Remove-Item -Path "$env:systemdrive\OneDriveTemp" -Recurse -ErrorAction SilentlyContinue 
Remove-Item -Path "$env:userprofile\OneDrive" -Recurse -ErrorAction SilentlyContinue
Set-RegistryItem "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1
Write-Host "Done!"

Write-Host `n"Removing OneDrive integration from Windows Explorer..."
@("\Wow6432Node", "\") | Foreach-Object { if (Test-Path "HKCR:$_\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") { Set-RegistryItem -Path "HKCR:$_\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0 } }
Write-Host "Done!"

Write-Host `n"Preventing OneDrive to be reinstalled for new users..."
Remove-ItemProperty -Path "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup" -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host `n"Removing additional OneDrive leftovers..."
Get-ScheduledTask -TaskPath '\' -TaskName "*OneDrive*" -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
foreach ($item in Get-ChildItem "$env:WinDir\WinSxS\*onedrive*") {
    Remove-Item -Recurse -ErrorAction SilentlyContinue $item.FullName
}
Write-Host "Done!"

Write-Host `n"Restoring explorer state (back to normality)..."
Start-Process $services[0] -Wait
Write-Host "Done!"
