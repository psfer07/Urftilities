# Optimizations set by psfer07

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}

Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\edit-regs.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Improving performance"
Write-Host "--> Optimizing system..."

[string]$PathToMultimediaSystemProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"

Write-Host `n"Optimizing general settings..."
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 0
Set-RegistryItem -Path "HKLM:\SYSTEM\ControlSet001\Services\Ndu" -Name "Start" -Value 4
Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host `n"Optimizing svchost.exe usage of memory..."
$RamInKB = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value $RamInKB
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "AutoDownload" -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host `n"Optimizing bootdown memory"
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache", "ClearPageFileAtShutdown" -Value 1, 0
Write-Host "Done!"

Write-Host `n"Optimizing multimedia system profile..."
Set-RegistryItem -Path "$PathToMultimediaSystemProfile" -Name "NetworkThrottlingIndex", "SystemResponsiveness" -Value 0xffffffff, 0

# Multimedia System Profile Tasks
foreach ($task in @("Audio", "Capture", "DisplayPostProcessing", "Distribution", "Games", "Playback", "Pro Audio", "Window Manager")) {
    
    $taskPath = "$PathToMultimediaSystemProfile\Tasks\$task"
    Set-RegistryItem -Path $taskPath -Name "Affinity", "Clock Rate", "GPU Priority", "Priority" -Value 0, 10000, 8, 6
    Set-RegistryItem -Path $taskPath -Name "Background Only", "Scheduling Category", "SFIO Priority" -Value "True", "Medium", "Normal" -Type String
}
Write-Host "Done!"

Write-Host `n"Disabling hibernation..."
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" -Name "PowerThrottlingOff" -Value 1
Set-RegistryItem -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" -Name "HibernateEnabled" -Value 0
Write-Host "Done!"

Write-Host `n"Decreasing processes kill time and menu show delay"
Set-RegistryItem -Path "HKLM:\Control Panel\Desktop" -Name "MenuShowDelay", "MenuShowDelay", "HungAppTimeout", "AutoEndTasks", "LowLevelHooksTimeout", "WaitToKillServiceTimeout" -Value 0, 5000, 4000, 1, 00001000, 00002000
Write-Host "Done!"

Write-Host `n"Disabling Windows auto maintenance tasks..."
Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "MaintenanceDisabled" -Value 1
Write-Host "Done!"
