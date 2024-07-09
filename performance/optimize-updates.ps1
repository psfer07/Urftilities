# Ensure the script runs as Administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\edit-regs.psm1"

Write-Step "Improving performance"
Write-Host "--> Optimizing Windows Update..."

$MsPolicies = "HKLM:\SOFTWARE\Policies\Microsoft"

# Set registry values
Write-Host `n"Disabling auto-update..."
Set-RegistryItem -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions", "ScheduledInstallDay", "ScheduledInstallTime", "NoAutoUpdate" -Value 2, 0, 3, 1
Write-Host "Done!"

Write-Host `n"Disabling seeding of updates to other computers via Group Policies..."
Set-RegistryItem -Path "$MsPolicies\Windows\DeliveryOptimization" "DODownloadMode" 0
$objSID = New-Object System.Security.Principal.SecurityIdentifier "S-1-1-0"
$EveryOne = $objSID.Translate([System.Security.Principal.NTAccount]).Value
takeown /F "$env:WinDIR\System32\MusNotification.exe" | Out-Null
icacls "$env:WinDIR\System32\MusNotification.exe" /deny "$($EveryOne):(X)" | Out-Null
takeown /F "$env:WinDIR\System32\MusNotificationUx.exe" | Out-Null
icacls "$env:WinDIR\System32\MusNotificationUx.exe" /deny "$($EveryOne):(X)" | Out-Null
Write-Host "Done!"

Write-Host `n"Disabling driver updates through Windows Update..."
Set-RegistryItem -Path "$MsPolicies\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Value 1
Set-RegistryItem -Path "$MsPolicies\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate", "DontSearchWindowsUpdate", "DriverUpdateWizardWuSearchEnabled" -Value 1, 1, 0
Set-RegistryItem -Path "$MsPolicies\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Value 1
Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" 0
Write-Host "Done!"

Write-Host `n"Disabling Windows Update automatic restart..."
Set-RegistryItem -Path "$MsPolicies\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers", "AUPowerManagement" -Value 1, 0
Write-Host "Done!"

Write-Host `n"Delaying updates arrival..."
Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate" -Name "BranchReadinessLevel", "DeferFeatureUpdatesPeriodInDays", "DeferQualityUpdatesPeriodInDays" -Value 20, 10, 4
Write-Host "Done!"
