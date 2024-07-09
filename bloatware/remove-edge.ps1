# Script Metadata
# Created by AveYo, source: https://raw.githubusercontent.com/AveYo/fox/main/Edge_Removal.bat
# Powershell Conversion and Refactor done by Chris Titus Tech
# Modified and optimized by psfer07


# Check if the script is already running as administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}

Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\edit-regs.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Removing bloatware"
Write-Host "--> Removing Microsoft Edge..."

Write-Host `n"Stopping processes (don't panic)..."
$processes = @('explorer.exe', 'Widgets.exe', 'widgetservice.exe', 'msedgewebview2.exe', 'MicrosoftEdge*', 'chredge.exe', 'msedge.exe', 'edge.exe', 'msteams.exe', 'msfamily.exe', 'WebViewHost.exe', 'Clipchamp.exe')
foreach ($process in $processes) { Start-Process taskkill.exe -ArgumentList "/f /im $process" -Wait -ErrorAction SilentlyContinue }
Write-Host "Done!"

Write-Host `n"Removing Microsoft Edge form the registry..."
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\msedge.exe"
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ie_to_edge_stub.exe"
    "HKEY_Users\S-1-5-21*\Software\Classes\microsoft-edge"
    "HKEY_Users\S-1-5-21*\Software\Classes\MSEdgeHTM"
)
foreach ($path in $registryPaths) { Remove-Item -Path $path -Recurse -ErrorAction SilentlyContinue }
Write-Host "Done!"

$EdgeExecutablePath = ($env:ProgramFiles, ${env:ProgramFiles(x86)})[[Environment]::Is64BitOperatingSystem] + '\Microsoft\Edge\Application\msedge.exe'
Set-RegistryItem -Path "HKLM:\SOFTWARE\Classes\microsoft-edge\shell\open\command", "HKLM:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command" -Name "(Default)" -Value "`"$EdgeExecutablePath`" --single-argument %%1" -ErrorAction SilentlyContinue

Write-Host `n"Preventing Microsoft Edge to be reinstalled automatically..."
$edgeProperties = @('InstallDefault', 'Install{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}', 'Install{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}')
$on_actions = @('on-os-upgrade', 'on-logon', 'on-logon-autolaunch', 'on-logon-startup-boost')

foreach ($base in @('HKLM:\SOFTWARE', 'HKLM:\SOFTWARE\Wow6432Node')) {
    foreach ($prop in $edgeProperties) {
        Remove-ItemProperty -Path "$base\Microsoft\EdgeUpdate" -Name $prop -ErrorAction SilentlyContinue
    }
    
    foreach ($launch in $on_actions) {
        @("56EB18F8-B008-4CBD-B6D2-8C97FE7E9062", "F3017226-FE2A-4295-8BDF-00C3A9A7E4C5") |
        ForEach-Object { Remove-Item -Path "$base\Microsoft\EdgeUpdate\Clients\{$_}\Commands\$launch" -ErrorAction SilentlyContinue }
    }
}
Write-Host "Done!"

Write-Host `n"Uninstalling Microsoft Edge core components..."
$registryPaths = @('HKCU:', 'HKLM:')
$nodes = @('', '\Wow6432Node')

foreach ($regPath in $registryPaths) {
    foreach ($node in $nodes) {
        foreach ($i in @("Microsoft Edge", "Microsoft Edge Update")) {
            Remove-ItemProperty -Path "$regPath\SOFTWARE${node}\Microsoft\Windows\CurrentVersion\Uninstall\$i" -Name 'NoRemove' -ErrorAction SilentlyContinue
        }
        Set-RegistryItem -Path "$regPath\SOFTWARE${node}\Microsoft\EdgeUpdateDev" -Name 'AllowUninstall' -Value 1
    }
}
Write-Host "Done!"

Write-Host `n"Removing Micrsooft Edge appx packages..."
$eolPackages = Get-AppxProvisionedPackage -Online   | Where-Object { "MicrosoftEdge" -contains $_.DisplayName }
$eolApps = Get-AppxPackage                -AllUsers | Where-Object { "MicrosoftEdge" -contains $_.Name }

foreach ($package in $eolPackages) { Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction SilentlyContinue }
foreach ($app     in $eolApps    ) { Remove-AppxPackage            -Package $app.PackageFullName   -AllUsers -ErrorAction SilentlyContinue }
Write-Host "Done!"

Write-Host `n"Removing Edge Leftovers..."
$leftovers = @(
    "$env:Public\Desktop\Microsoft Edge.lnk",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    "${Env:ProgramFiles(x86)}\Microsoft",
    "$Env:LOCALAPPDATA\Microsoft\Edge"
)
foreach ($path in $leftovers) { Remove-Item -Path $path -Recurse -ErrorAction SilentlyContinue }
Write-Host "Done!"

Write-Host `n"Restoring explorer state (back to normality)..."
Start-Process $processes[0]
Write-Host "Done!"
