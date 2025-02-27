param (
    [Alias("n")][switch]$normal,
    [Alias("f")][switch]$full,
    [Alias("s")][switch]$silent,
    [Alias("r")][switch]$restart
)

# Bypass any execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Some customization
$Host.UI.RawUI.BackGroundColor = 'Black'
$Host.UI.RawUI.WindowTitle = 'Urftilities'

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath -normal:$normal -full:$full -silent:$silent -restart:$restart`"" -Verb RunAs
    exit 1
}

if ($silent) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit 0
}

function Invoke-FolderScripts {
    param ([string]$Path)
    foreach ($file in Get-ChildItem -Path "$PSScriptRoot\$path" -Filter *.ps1) {
        if ($silent) { . $file.FullName | Out-Null } else { . $file.FullName }
    }
}

Import-Module -DisableNameChecking "$PSScriptRoot\modules\titles.psm1"

Clear-Host
if (!($normal -or $full)) {
    Write-Step "Select Urftilities mode"
    Write-Host `n`n"You can choose between normal and full mode:"`n
    Write-Host "1. Normal mode"
    Write-Host "2. Full mode (also executes the normal mode)"
    do {
        Write-Host
        $mode = Read-Host "Choose option"
    } while ( $mode -notin @(1, 2) )
    if ($mode -eq 1) { $normal = $true } else { $full = $true }
}
Clear-Host
if ($full -and !$restart) { Write-Warning `n"Full mode selected. This will last a lot more compared to the normal mode. Reboot is highly recommended" }

Write-Step "Removing temporary files"
Write-Host `n"--> Deleting temporary files with cleanmgr..."
cleanmgr.exe /VERYLOWDISK
Write-Host "Done!"

Write-Host `n"--> Removing any queued updates..."
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null
Stop-Service -Name "wuauserv", "UsoSvc", "bits", "dosvc" -ErrorAction SilentlyContinue
Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\*" -Recurse -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host `n"--> Removing network cache..."
arp -d * | Out-Null; nbtstat -RR | Out-Null; ipconfig /flushdns | Out-Null; ipconfig /registerdns | Out-Null
Write-Host "Done!"

if ($full) {
    Write-Step "Creating a restore point"
    Enable-ComputerRestore -Drive "$Env:SYSTEMDRIVE\"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0 -Force
    Checkpoint-Computer -Description "Urftilities $(Get-Date -Format 'HH:mm:ss dd-MM-yy')" -RestorePointType "MODIFY_SETTINGS"
    
    Write-Step "Running OOSU10++"
    Start-Process -FilePath "$PSScriptRoot\privacy\OOSU10.exe" -ArgumentList "`"$PSScriptRoot\privacy\ooshutup10.cfg`" /nosrp /quiet"
    
    Invoke-FolderScripts("bloatware")
    Invoke-FolderScripts("performance")
    Invoke-FolderScripts("privacy")
    
    Write-Step "Full optimizations finished!"
    
    # Ask whether reboot or not
    if (!$silent -and !$restart) {
        Add-Type -AssemblyName System.Windows.Forms
        $title = "Urftilities has finished!"
        $message = "All the optimizations have been applied successfully. To completely settle down all this configurations, it is mandatory to restart your computer, so you can restart it now or manually later."
        $buttons = [System.Windows.Forms.MessageBoxButtons]::YesNo
        $icon = [System.Windows.Forms.MessageBoxIcon]::Warning
        $response = [System.Windows.Forms.MessageBox]::Show($message, $title, $buttons, $icon, [System.Windows.Forms.MessageBoxDefaultButton]::Button1)
        if ($response -eq [System.Windows.Forms.DialogResult]::Yes) { $restart = $true }
    }
}
# What could this mean ¯\_(ツ)_/¯
if ($restart -and $full) { Restart-Computer }
