if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}

Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\edit-regs.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Improving performance"
Write-Host "--> Optimizing Windows network management..."

# TCP/IP Settings
Write-Host `n"Adjusting packages sizes..."
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "MaxUserPort", "TcpTimedWaitDelay", "DefaultTTL" -Value 65534, 30, 64
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip" -Name "ReceiveSegmentCoalescing", "ReceiveSideScaling" -Value 1
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip" -Name "Large Send Offload", "Checksum Offload", "EcnCapability", "Chimney", "Timestamps" -Value 2
Write-Host "Done!"

# LAN Manager Server Settings
Write-Host `n"Improving network traffic..."
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "Size" -Value 1

# QoS and Network Provider Settings
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" -Name "Do not use NLA" -Value 1
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" -Name "NonBestEffortLimit" -Value 0

# Default connection settings
$PathToInternetSettings = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections"
$Data = (Get-ItemProperty -Path $PathToInternetSettings -Name DefaultConnectionSettings).DefaultConnectionSettings
$Data[8] = 3
Set-RegistryItem -Path $PathToInternetSettings -Name DefaultConnectionSettings -Value $Data
Write-Host "Done!"
