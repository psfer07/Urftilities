# Script Metadata
# Created by AveYo, source: https://raw.githubusercontent.com/AveYo/fox/main/Edge_Removal.bat
# Powershell Conversion and Refactor done by psfer07

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
$processes = @('explorer.exe', 'Widgets.exe', 'widgetservice.exe', 'msedgewebview2.exe', 'MicrosoftEdge*', 'chredge.exe', 'msedge.exe', 'msedgewebview2.exe', 'edge.exe', 'msfamily.exe', 'WebViewHost.exe', 'Clipchamp.exe')
foreach ($process in $processes) { Start-Process taskkill.exe -ArgumentList "/f /im $process" -Wait -ErrorAction SilentlyContinue }
Write-Host "Done!"

$hives = 'HKCU:\SOFTWARE', 'HKLM:\SOFTWARE', 'HKCU:\SOFTWARE\Policies', 'HKLM:\SOFTWARE\Policies'

Write-Host `n"Removing Edge from the registry..."
foreach ($uid in @('{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}', '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}', '{F3C4FE00-EFD5-403B-9569-398A20F1BA4A}')) {
    foreach ($program in @('msedge', 'msedgeupdate', 'msedgewebview')) {
        foreach ($hive in $hives) {
            Remove-ItemProperty "$hive\Microsoft\EdgeUpdate" -Name 'DoNotUpdateToEdgeWithChromium' -ErrorAction SilentlyContinue
            Remove-ItemProperty "$hive\Microsoft\EdgeUpdate" -Name 'UpdaterExperimentationAndConfigurationServiceControl' -ErrorAction SilentlyContinue
            Remove-ItemProperty "$hive\Microsoft\EdgeUpdate" -Name "InstallDefault" -ErrorAction SilentlyContinue
            Remove-ItemProperty "$hive\Microsoft\EdgeUpdate" -Name "Install${uid}" -ErrorAction SilentlyContinue
            Remove-ItemProperty "$hive\Microsoft\EdgeUpdate" -Name "EdgePreview${uid}" -ErrorAction SilentlyContinue
            Remove-ItemProperty "$hive\Microsoft\EdgeUpdate" -Name "Update${uid}" -ErrorAction SilentlyContinue
            Remove-ItemProperty "$hive\Microsoft\EdgeUpdate\ClientState\*" -Name 'experiment_control_labels' -ErrorAction SilentlyContinue
            Remove-Item "$hive\Microsoft\EdgeUpdate\Clients\${uid}\Commands" -ErrorAction SilentlyContinue -Confirm:$false -Force
            Remove-ItemProperty "$hive\Microsoft\EdgeUpdateDev\CdpNames" -Name "$program*" -ErrorAction SilentlyContinue
            Set-RegistryItem "$hive\Microsoft\EdgeUpdateDev" "CanContinueWithMissingUpdate", "AllowUninstall" 1
        }
    }
}

$MSEDGE = "$(@($env:ProgramFiles, ${env:ProgramFiles(x86)}))\Microsoft\Edge\Application\msedge.exe"
Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" -Name "msedge.exe" -ErrorAction SilentlyContinue
Remove-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" -Name "ie_to_edge_stub.exe" -ErrorAction SilentlyContinue
Remove-RegistryItem "HKCU:\S-1-5-21*\Software\Classes\microsoft-edge", "HKCU:\S-1-5-21*\Software\Classes\MSEdgeHTM"
Set-RegistryItem "HKLM:\SOFTWARE\Classes\microsoft-edge\shell\open\command", "HKLM:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command" '(Default)' "`"$MSEDGE`" --single-argument %%1"

$cfg = @{
    Register                  = $true
    ForceApplicationShutdown  = $true
    ForceUpdateFromAnyVersion = $true
    DisableDevelopmentMode    = $true
}
Get-ChildItem "$env:SystemRoot\SystemApps\Microsoft.Win32WebViewHost*\AppxManifest.xml" -Recurse -ErrorAction SilentlyContinue | Add-AppxPackage @cfg
Get-ChildItem "$env:ProgramFiles\WindowsApps\MicrosoftWindows.Client.WebExperience*\AppxManifest.xml" -Recurse -ErrorAction SilentlyContinue | Add-AppxPackage @cfg
Write-Host "Done!"

Write-Host `n"Restoring Windows Explorer (back to normallity)..."
Start-Process $processes[0] -Wait
Write-Host "Done!"

Write-Host `n"Removing Edge & WebView AppX packages..."
foreach ($package in Get-AppxPackage) {
    $id = $package.PackageFullName
    foreach ($name in @("MicrosoftEdge", "Win32WebViewHost", "WebExperience")) {
        if ($id -like "*$name*") { Remove-AppxPackage -Package $id -ErrorAction SilentlyContinue }
    }
}
Write-Host "Done!"

Write-Host `n"Uninstalling Microsoft Edge components..."
$nodes = @('', 'SOFTWARE', 'SOFTWARE\Wow6432Node')
foreach ($node in $nodes) {
    foreach ($hive in $hives) {
        foreach ($name in @("Microsoft Edge", "Microsoft Edge Update", "Microsoft EdgeWebView")) {
            Remove-RegistryItem "$hive\${node}Microsoft\Windows\CurrentVersion\Uninstall\$name"
        }
    }
}
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
