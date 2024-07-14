# Written by psfer07
# Ensure the script runs as Administrator
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}

Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\edit-regs.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Enhancing privacy"
Write-Host "--> Enhancing privacy..."
Write-Host `n"Disabling general telemetry..."
Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowDeviceNameInTelemetry", "AllowTelemetry" -Value 0
Set-RegistryItem -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Value 1
Set-RegistryItem -Path "HKCU:\Printers\Defaults" -Name "NetID" -Value "{00000000-0000-0000-0000-000000000000}" -Type "String"
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC", "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value 0
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization" -Name "AllowInputPersonalization" -Value 0
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Value 0
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Value 0
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 0
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Value 0

# Generic privacy tweaks
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed", "PublishUserActivities", "UploadUserActivities" -Value 0
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Clipboard" -Name "EnableClipboardHistory", "CloudClipboardAutomaticUpload", "EnableCloudClipboard" -Value 0
Write-Host "Done!"

Write-Host `n"Disabling Location Tracking..."
@("Permissions", "Overrides") |
ForEach-Object { Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\$_\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Value 0 }
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation", "DisableLocationScripting", "DisableWindowsLocationProvider" -Value 1
Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -Type "String"
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Value 0

# Disable some startup event traces (AutoLoggers)"`n
$autoLoggerDir = "$env:PROGRAMDATA\Microsoft\Diagnosis\ETLLogs\AutoLogger"
Remove-RegistryItem "$autoLoggerDir\AutoLogger-Diagtrack-Listener.etl"
icacls $autoLoggerDir /deny "SYSTEM:(OI)(CI)F" | Out-Null
Set-RegistryItem -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" -Name "Start" -Value 0
Write-Host "Done!"

Write-Host `n"Disabling settings synchronization..."
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync" -Name "BackupPolicy", "DeviceMetadataUploaded", "PriorLogons", "SyncPolicy" -Value 0x3c, 0, 1, 5
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0

$groups = @("Accessibility", "AppSync", "BrowserSettings", "Credentials", "DesktopTheme",
    "Language", "PackageState", "Personalization", "StartLayout", "Windows")
foreach ($group in $groups) { Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\$group" -Name "Enabled" -Value 0 }
Write-Host "Done!"

Write-Host `n"Disabling diagnostic data..."
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0
Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey" -Name "EnableEventTranscript" -Value 0
@("userNotificationListener", "appDiagnostics") | ForEach-Object { Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\$_" -Name "Value" -Value "Deny" -Type "String" }
Write-Host "Done!"

Write-Host `n"Uninstall and remove Cortana"
Get-AppxPackage -AllUsers Microsoft.549981C3F5F10 | Remove-AppxPackage
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 0
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection", "RestrictImplicitTextCollection" -Value 1
Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Name "AllowLinguisticDataCollection" -Value 0
Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\WindowsMitigation" -Name "UserPreference" -Value 3
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0
Write-Host "Done!"

Write-Host `n"Optimizing Microsoft Edge settings..."
$edge = "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge"
$dwords = @(
    "BrowserReplacementEnabled"
    "HideFirstRunExperience"
    "HideImportEdgeFavoritesPrompt"
    "HideSyncSetupExperience"
    "FavoritesBarVisibility"
)
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name $dwords -Value 1
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "AutoplayAllowed" -Value "AllowOnce" -Type "String"
Set-RegistryItem -Path "$edge\Main" -Name "DoNotTrack" -Value 1
Set-RegistryItem -Path "$edge\User\Default\SearchScopes" -Name "ShowSearchSuggestionsGlobal" -Value 0
Set-RegistryItem -Path "$edge\FlipAhead" -Name "FPEnabled" -Value 0
Set-RegistryItem -Path "$edge\PhishingFilter" -Name "EnabledV9" -Value 0
Write-Host "Done!"

Write-Host `n"Disabling background access of default apps..."
[string]$BgAccessApps = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
foreach ($key in (Get-ChildItem $BgAccessApps)) {
    Set-RegistryItem -Path ($BgAccessApps + $key.PSChildName) -Name "Disabled" -Value 1
}
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BackgroundAppGlobalToggle" -Value 0


[string]$devices = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global"
if (Test-Path $devices) {
    Write-Host `n"Denying device access..."
    Set-RegistryItem -Path $devices -Name "Type", "Value", "InitialAppValue" -Value "LooselyCoupled" -Type "String"
    Set-RegistryItem -Path "$devices\LooselyCoupled" -Name "Value", "InitialAppValue" -Value "Deny", "Unspecified" -Type "String"
    foreach ($key in (Get-ChildItem $devices)) {
        if ($key.PSChildName -ne "LooselyCoupled") {
            Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\" + $key.PSChildName -Name "Type", "Value", "InitialAppValue" -Value "InterfaceClass", "Deny", "Unspecified" -Type "String"
        }
    }
}
Write-Host "Done!"

Write-Host `n"Disabling share wifi networks..."
$user = New-Object System.Security.Principal.NTAccount($env:UserName)
$sid = $user.Translate([System.Security.Principal.SecurityIdentifier]).value
Set-RegistryItem -Path ("HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features\" + $sid) -Name "FeatureStates" -Value 0x33c
Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features" -Name "WiFiSenseCredShared", "WiFiSenseOpen" -Value 0
Write-Host "Done!"

Write-Host `n"Disabling Microsoft Office telemetry..."
Set-RegistryItem -Path "HKCU:\SOFTWARE\Policies\Microsoft\Office\15.0\osm", "HKCU:\SOFTWARE\Policies\Microsoft\Office\16.0\osm" -Name "Enablelogging", "EnableUpload" -Value 0

$properties = @(
    "accesssolution"
    "olksolution"
    "onenotesolution"
    "pptsolution"
    "projectsolution"
    "publishersolution"
    "visiosolution"
    "wdsolution"
    "xlsolution"
)
Set-RegistryItem -Path "HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\osm\preventedapplications" -Name $properties -Value 1 <# -ErrorAction SilentlyContinue #>

$properties2 = @(
    "agave"
    "appaddins"
    "comaddins"
    "documentfiles"
    "templatefiles"
)
Set-RegistryItem -Path "HKCU:\Software\Policies\moffice\16.0\osm\preventedsolutiontypes" -Name $properties2 -Value 1 <# -ErrorAction SilentlyContinue #>

foreach ($version in @("15.0", "16.0")) {
    $regPaths = @(
        "HKCU:\SOFTWARE\Microsoft\Office\$version\Outlook\Options\Mail",
        "HKCU:\SOFTWARE\Microsoft\Office\$version\Outlook\Options\Calendar",
        "HKCU:\SOFTWARE\Microsoft\Office\$version\Word\Options",
        "HKCU:\SOFTWARE\Policies\Microsoft\Office\$version\OSM",
        "HKCU:\SOFTWARE\Microsoft\Office\Common\ClientTelemetry",
        "HKCU:\SOFTWARE\Microsoft\Office\$version\Common\ClientTelemetry",
        "HKCU:\SOFTWARE\Microsoft\Office\$version\Common",
        "HKCU:\SOFTWARE\Microsoft\Office\$version\Common\Feedback"
    )
    $regNames = @(
        "EnableLogging", "EnableCalendarLogging", "EnableUpload"
        "VerboseLogging", "QMEnable", "Enabled"
    )
    Set-RegistryItem -Path $regPaths -Name $regNames -Value 0
    Set-RegistryItem -Path $regPaths -Name "DisableTelemetry" -Value 1
}
Write-Host "Done!"

Write-Host `n"Running some Windows Media Player Optimizations..."
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\WMDRM" -Name DisableOnline -Value 1
Set-RegistryItem -Path "HKCU:\SOFTWARE\Microsoft\MediaPlayer\Preferences" -Name UsageTracking -Value 0
Set-RegistryItem -Path "HKCU:\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventCDDVDMetadataRetrieval", "PreventMusicFileMetadataRetrieval", "PreventRadioPresetsRetrieval" -Value 1, 1, 0

# Chrome
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe") {
    Write-Host `n"Optimizing Google Chrome..."
    Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "ChromeCleanupEnabled", "ChromeCleanupReportingEnabled", "MetricsReportingEnabled" -Type "String" -Value 0
    Set-RegistryItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\software_reporter_tool.exe" -Name "Debugger" -Type "String" -Value %windir%\System32\taskkill.exe 
}
# Firefox
if (Test-Path "HKLM:\SOFTWARE\Mozilla\Mozilla Firefox") { Write-Host `n"Optimizing Mozilla Firefox..."; Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Mozilla\Firefox" -Name "DisableTelemetry", "DisableDefaultBrowserAgent" -Value 1 }
Write-Host "Done!"
