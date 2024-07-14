### This script removes unwanted Apps that come with Windows. ###
### If you  do not want to remove certain Apps comment out the corresponding lines in the PowerShell script.###
### Author of this script: https://github.com/W4RH4WK/Debloat-Windows-10
# Optimized by psfer07

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}

Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\edit-regs.psm1"
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Removing bloatware"
Write-Host `n`n"--> Removing unwanted apps..."

Write-Host `n"Removing bundle packages from your system (this step usually takes a bit more time)..."
[string]$ContentDeliveryManager = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
$apps = @(
    # Default Windows apps
    "Microsoft.3DBuilder"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTranslator"
    "Microsoft.BingWeather"
    "Microsoft.FreshPaint"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsCamera"
    "Microsoft.Windows.Photos"
    "Microsoft.Windows.DevHome"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.WindowsFeedbackHub"

    #Redstone apps
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.BingTravel"
    "Microsoft.WindowsReadingList"

    # Redstone 5 apps
    "Microsoft.MixedReality.Portal"
    "Microsoft.ScreenSketch"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.YourPhone"

    # non-Microsoft
    "2FE3CB00.PicsArt-PhotoStudio"
    "46928bounde.EclipseManager"
    "4DF9E0F8.Netflix"
    "613EBCEA.PolarrPhotoEditorAcademicEdition"
    "6Wunderkinder.Wunderlist"
    "7EE7776C.LinkedInforWindows"
    "89006A2E.AutodeskSketchBook"
    "9E2F88E3.Twitter"
    "A278AB0D.DisneyMagicKingdoms"
    "A278AB0D.MarchofEmpires"
    "ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC
    "CAF9E577.Plex"  
    "ClearChannelRadioDigital.iHeartRadio"
    "D52A8D61.FarmVille2CountryEscape"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "Drawboard.DrawboardPDF"
    "Facebook.Facebook"
    "Fitbit.FitbitCoach"
    "Flipboard.Flipboard"
    "GAMELOFTSA.Asphalt8Airborne"
    "KeeperSecurityInc.Keeper"
    "Microsoft.BingNews"
    "NORDCURRENT.COOKINGFEVER"
    "PandoraMediaInc.29680B314EFC2"
    "Playtika.CaesarsSlotsFreeCasino"
    "ShazamEntertainmentLtd.Shazam"
    "SlingTVLLC.SlingTV"
    "SpotifyAB.SpotifyMusic"
    "TheNewYorkTimes.NYTCrossword"
    "ThumbmunkeysLtd.PhototasticCollage"
    "TuneIn.TuneInRadio"
    "WinZipComputing.WinZipUniversal"
    "XINGAG.XING"
    "flaregamesGmbH.RoyalRevolt2"
    "king.com.*"
    "king.com.BubbleWitch3Saga"

    "*OneCalendar*"
    "*CandyCrush*"
    "*HiddenCityMysteryofShadows*"
    "*Hulu*"
    "*Dolby*"
    "*HiddenCity*"
    "*AdobePhotoshopExpress*"
    "*ACGMediaPlayer*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    "*Speed Test*"
    "*Viber*"
    "*HotspotShieldFreeVPN*"
    "*Royal Revolt*"
    "*Flipboard*"

    # apps which other apps depend on
    "Microsoft.Advertising.Xaml"
)
foreach ($app in $apps) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online
}
Write-Host "Done!"

Write-Host `n"Removing installing suggested apps on start menu..."
Remove-Item -Path "$ContentDeliveryManager\Subscriptions" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "$ContentDeliveryManager\SuggestedApps" -Recurse -ErrorAction SilentlyContinue
Write-Host "Done!"

Write-Host `n"Preventing unwanted apps from re-installing..."
$cdm = @(
    "ContentDeliveryAllowed"
    "FeatureManagementEnabled"
    "OemPreInstalledAppsEnabled"
    "PreInstalledAppsEnabled"
    "PreInstalledAppsEverEnabled"
    "SilentInstalledAppsEnabled"
    "SubscribedContentEnabled"
    "SystemPaneSuggestionsEnabled"
    "RotatingLockScreenOverlayEnabled"
    "RotatingLockScreenEnabled"
    "RemediationRequired"
    "SoftLandingEnabled"
)
Set-RegistryItem -Path $ContentDeliveryManager -Name $cdm -Value 0
Write-Host "Done!"

Write-Host `n"Disabling suggested apps..."
$subscon = Get-ItemProperty -Path $ContentDeliveryManager | ForEach-Object { $_.PSObject.Properties.Name | Where-Object { $_ -like "SubscribedContent*" } }
Set-RegistryItem -Path $ContentDeliveryManager -Name $subscon -Value 0

# Prevents "Suggested Applications" returning
$CloudContent = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
Set-RegistryItem -Path "$CloudContent" -Name "ConfigureWindowsSpotlight", "IncludeEnterpriseSpotlight" -Value 2, 0
Set-RegistryItem -Path "$CloudContent" -Name "DisableThirdPartySuggestions", "DisableTailoredExperiencesWithDiagnosticData", "DisableWindowsSpotlightFeatures", "DisableWindowsSpotlightOnActionCenter", "DisableWindowsSpotlightOnSettings", "DisableWindowsSpotlightWindowsWelcomeExperience" -Value 1
Set-RegistryItem -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableMmx" -Value 0
Write-Host "Done!"

Write-Host `n"Removing bloatware from the registry..."
$Keys = @(
    #Remove Background Tasks
    "BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
    "BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
    "BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
            
    #Windows File
    "File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
            
    #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
    "Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
    "Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
            
    #Scheduled Tasks to delete
    "PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
            
    #Windows Protocol Keys
    "Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
               
    #Windows Share Target
    "ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
)
foreach ($Key in $Keys) { Remove-Item "HKCR:\Extensions\ContractId\Windows.\$Key" -Recurse -ErrorAction SilentlyContinue }
Write-Host "Done!"
