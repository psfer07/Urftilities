# Modified from https://github.com/LeDragoX/Win-Debloat-Tools by psfer07

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Enhancing privacy"
Write-Host "--> Disabling invasive Tasks"

$tasks = @(
    # Office Telemetry Tasks
    "\Microsoft\Office\OfficeTelemetryAgentLogOn"
    "\Microsoft\Office\OfficeTelemetryAgentFallBack"

    # Customer Experience Improvement Program (CEIP) Tasks
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
    "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"

    # Location Tasks
    "\Microsoft\Windows\Location\Notifications"
    "\Microsoft\Windows\Location\WindowsActionDialog"

    # Application Experience Tasks
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"

    # Maps Tasks
    "\Microsoft\Windows\Maps\MapsToastTask"
    "\Microsoft\Windows\Maps\MapsUpdateTask"

    # Mobile Broadband Tasks
    "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"

    # Retail Demo Task
    "\Microsoft\Windows\Retail Demo\CleanupOfflineContent"

    # Family Safety Tasks
    "\Microsoft\Windows\Shell\FamilySafetyMonitor"
    "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"
    "\Microsoft\Windows\Shell\FamilySafetyUpload"

    # Windows Media Sharing Task
    "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"

    # Feedback Task
    "\Microsoft\Windows\Feedback\Siuf\DmClient"

    # Remote Assistance Task
    "\Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask"

    # Windows Defender Tasks
    "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance"
    "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup"
    "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan"
    "\Microsoft\Windows\Windows Defender\Windows Defender Verification"

    # Other tasks for privacy and performance
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver"
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    "\Microsoft\Windows\CloudExperienceHost\CreateObjectTask"
    "\Microsoft\Windows\Defrag\ScheduledDefrag"
    "\Microsoft\Windows\Servicing\StartComponentCleanup"
    "\Microsoft\Windows\Shell\FamilySafetyRefresh"
    "\Microsoft\Windows\Shell\IndexerAutomaticMaintenance"
    "\Microsoft\Windows\SettingSync\BackgroundUploadTask"
)

foreach ($task in $tasks) {
    $parts = $task.split('\')
    $path = $parts[0..($parts.length - 2)] -join '\'
    Disable-ScheduledTask -TaskName $parts[-1] -TaskPath $path -ErrorAction SilentlyContinue | Out-Null
}
Write-Host "Done!"
