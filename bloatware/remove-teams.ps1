# Remade by psfer07, originaly created by asheroto

# Check if the script is already running as administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}

Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\edit-regs.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Removing bloatware"
Write-Host "--> Uninstalling Microsoft Teams..."
Write-Host `n"Getting neccessary data from Microsoft Teams registry..."
$result = @()
$uninstallKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)
foreach ($key in $uninstallKeys) {
    if (Test-Path $key) {
        Get-Item $key | Get-ChildItem | Where-Object { $_.GetValue("DisplayName") -like "*Teams*" } |
        ForEach-Object {
            $displayName = (Get-ItemProperty -Path $_.PSPath).DisplayName
            $uninstallString = (Get-ItemProperty -Path $_.PSPath).UninstallString
            if ($displayName -and $uninstallString) {
                $obj = [PSCustomObject]@{
                    DisplayName     = $displayName
                    UninstallString = $uninstallString
                }
                $result += $obj
            }
        }
    }
}
Write-Host "Done!"

Write-Host `n"Stoping Microsoft Teams services..."
$teamsProcesses = Get-Process | Where-Object { $_.ProcessName -like "*Teams*" -or $_.Path -like "*Teams.exe*" }
$teamsProcesses | ForEach-Object { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
Write-Host "Done!"

Write-Host `n"Uninstalling Microsoft Teams packages thanks to the data obtained from the registry..."
foreach ($info in $result) {
    $uninstallString = $info.UninstallString
    if (-not [string]::IsNullOrWhiteSpace($uninstallString)) {
        if ($uninstallString -match "msiexec.exe\s*/[XxIi]\{([^\}]+)\}") {
            $productGUID = $matches[1]
            $filePath = "msiexec.exe" # For MSI packages
            $argList = "/x {${productGUID}} /qn"
        }
        else {
            $filePath = $uninstallString.Split(" ")[0] # For non-MSI packages
            $argList = $uninstallString.Substring($filePath.Length).Trim()
        }
        if ($filePath -ieq "msiexec.exe" -or (Test-Path $filePath)) {
            $proc = Start-Process -FilePath $filePath -ArgumentList $argList -PassThru
            $proc.WaitForExit()
        }
    }
}
if (Test-Path "${env:ProgramFiles(x86)}\Teams Installer\Teams.exe") {
    Start-Process -FilePath "${env:ProgramFiles(x86)}\Teams Installer\Teams.exe" -ArgumentList "--uninstall" -PassThru
}
if ( Test-Path "$env:APPDATA\Microsoft\Teams\Update.exe") {
    Start-Process -FilePath "$env:APPDATA\Microsoft\Teams\Update.exe" -ArgumentList "-uninstall -s" -PassThru
}
if (Test-Path "${env:ProgramFiles(x86)}\Microsoft\Teams\current\Update.exe") {
    Start-Process -FilePath "${env:ProgramFiles(x86)}\Microsoft\Teams\current\Update.exe" -ArgumentList "-uninstall -s" -PassThru
}
Get-AppxPackage "*Teams*" | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage "*Teams*" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host `n"Removing Microsoft Teams leftovers..."
$names = @('Teams', 'TeamsMachineUninstallerLocalAppData', 'TeamsMachineUninstallerProgramData', 'com.squirrel.Teams.Teams', 'TeamsMachineInstaller')
@("HKCU:", "HKLM:") |
ForEach-Object { Remove-ItemProperty -Path "$_\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name $names -ErrorAction SilentlyContinue -WarningAction SilentlyContinue }
@("HKCU:", "HKLM:") |
ForEach-Object { Remove-ItemProperty -Path "$_\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name $names -ErrorAction SilentlyContinue -WarningAction SilentlyContinue }
Remove-Item -Include "Microsoft Teams" -Path "$env:HOMEPATH\Desktop\*", "$env:PUBLIC\Desktop\*" -ErrorAction SilentlyContinue
@("Microsoft Teams", "Microsoft Teams classic (work or school)") |
ForEach-Object { Remove-Item -Include $_ -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs", "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs" }
@("TeamsPresenceAddin", "TeamsMeetingAddin") |
ForEach-Object { Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\$_" -Recurse -ErrorAction SilentlyContinue }
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft Teams" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Teams" -Recurse -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host `n"Disabling future installations to run at startup..."
@("HKCU:", "HKLM:") |
ForEach-Object { Remove-Item -Path "$_\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Teams" -Recurse -ErrorAction SilentlyContinue }
@("HKCU:", "HKLM:") |
ForEach-Object { Set-RegistryItem -Path "$_\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Value 3 }
Write-Host "Done!"

Write-Host `n"Preventing Teams to be reinstalled..."
Set-RegistryItem -Path "HKLM\SOFTWARE\Policies\Microsoft\Office\16.0\common\officeupdate" -Name "PreventTeamsInstall" -Value 1
Write-Host "Done!"
