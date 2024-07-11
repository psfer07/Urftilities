if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Improving performance"
Write-Host "-->Repairing system..."

Write-Host `n"Restoring default hosts system file..."
$RestoreHosts = "# Copyright (c) 1993-2009 Microsoft Corp.`n#`n# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.`n#`n# This file contains the mappings of IP addresses to host names. Each`n# entry should be kept on an individual line. The IP address should`n# be placed in the first column followed by the corresponding host name.`n# The IP address and the host name should be separated by at least one`n# space.`n#`n# Additionally, comments (such as these) may be inserted on individual`n# lines or following the machine name denoted by a '#' symbol.`n#`n# For example:`n#`n#      102.54.94.97     rhino.acme.com          # source server`n#       38.25.63.10     x.acme.com              # x client host`n`n# localhost name resolution is handled within DNS itself.`n#    127.0.0.1       localhost`n#    ::1             localhost"

Push-Location -Path "$env:SystemRoot\System32\drivers\etc\"
Write-Output $RestoreHosts > .\hosts; Pop-Location
Write-Host "Done!"

Write-Host `n"Resetting Windows Store cache..."
Start-Process wsreset -NoNewWindow -Wait
taskkill /F /IM WinStore.App.exe | Out-Null
Write-Host "Done!"

Write-Host `n"Removing any BITS worker tranfer..."
Get-BitsTransfer | Remove-BitsTransfer
Write-Host "Done!"

Write-Host `n"Running SFC with scannow..."
Start-Process sfc.exe -ArgumentList "-ScanNow" -Wait
Write-Host "Done!"

Write-Host `n"Running DISM with ScanHealth..."
Start-Process Dism.exe -ArgumentList "-Online -CleanUp-Image -ScanHealth" -Wait
Write-Host "Done!"

Write-Host `n"Running DISM with RestoreHealth..."
Start-Process Dism.exe -ArgumentList "-Online -CleanUp-Image -RestoreHealth" -Wait
Write-Host "Done!"


Write-Host `n"Stopping explorer (don't panic)..."
Start-Process taskkill.exe -ArgumentList "/F /IM explorer.exe" -Wait
Write-Host "Done!"

Write-Host `n"Readding Windows Store installed packages..."
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableXamlStartMenu" -Value 0
Get-AppxPackage -AllUsers | ForEach-Object {
    Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
}
Write-Host "Done!"

Write-Host `n"Restoring explorer state (back to normality)..."
Start-Process explorer.exe
Write-Host "Done!"

Write-Host `n"Renewing network interfaces..."
ipconfig -Release | Out-Null; ipconfig -Release6 | Out-Null; ipconfig -Renew *Ethernet* | Out-Null; ipconfig -Renew6 *Ethernet* | Out-Null; ipconfig -FlushDns | Out-Null
Write-Host "Done!"
