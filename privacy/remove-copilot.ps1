# Script only useful for Windows 11 systems
if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild -gt 22000) {
    # Ensure the script runs as Administrator
    if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit 1
    }
    Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

    Write-Step "Enhancing privacy"
    Write-Host "--> Removing Microsoft Copilot"

    Write-Host `n"Removing unnecessary permissions and software..."
    # Set registry keys
    @("HKCU:", "HKLM:") | ForEach-Object {
        Set-ItemProperty -Path "$_\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "$_\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Value 1 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "$_\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 1 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "$_\Software\Microsoft\input\Settings" -Name "InsightsEnabled" -Value 1 -ErrorAction SilentlyContinue
    }
    gpupdate /force | Out-Null

    # Removing AI appx packages
    $provisionedPackages = Get-AppxProvisionedPackage -Online
    $installedPackages = Get-AppxPackage -AllUsers
    $storePath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore'
    $users = @( 'S-1-5-18' )
    $aipackages = @(
        'MicrosoftWindows.Client.Photon',
        'MicrosoftWindows.Client.AIX',
        'MicrosoftWindows.Client.CoPilot',
        'Microsoft.Windows.Ai.Copilot.Provider'
    )

    if (Test-Path $storePath) {
        $users += Get-ChildItem $storePath |
        Where-Object { $_ -like '*S-1-5-21*' } |
        ForEach-Object { $_.PSChildName }
    }

    $eolPackages = @()

    foreach ($package in $aipackages) {
        $matchingProvisionedPackages = $provisionedPackages | Where-Object { $_.PackageName -like "*$package*" }
        $matchingInstalledPackages = $installedPackages | Where-Object { $_.PackageFullName -like "*$package*" }

        foreach ($provisionedPackage in $matchingProvisionedPackages) {
            $PackageName = $provisionedPackage.PackageName
            $PackageFamilyName = ($installedPackages | Where-Object { $_.Name -eq $provisionedPackage.DisplayName }).PackageFamilyName

            New-Item "$storePath\Deprovisioned\$PackageFamilyName"
            foreach ($sid in $users) {
                New-Item "$storePath\EndOfLife\$sid\$PackageName"
            }
            dism /online /set-nonremovableapppolicy /packagefamily:$PackageFamilyName /nonremovable:0
            Remove-AppxProvisionedPackage -PackageName $PackageName -Online -AllUsers

            $eolPackages += $PackageName
        }

        foreach ($installedPackage in $matchingInstalledPackages) {
            $PackageFullName = $installedPackage.PackageFullName

            New-Item "$storePath\Deprovisioned\$installedPackage.PackageFamilyName"
            foreach ($sid in $users) {
                New-Item "$storePath\EndOfLife\$sid\$PackageFullName"
            }
            Write-Host `n"Removing more packages..."
            dism /online /set-nonremovableapppolicy /packagefamily:$installedPackage.PackageFamilyName /nonremovable:0
            Remove-AppxPackage -Package $PackageFullName -AllUsers

            $eolPackages += $PackageFullName
        }
    }
    Write-Host "Done!"

    Write-Host `n"Preventing copilot reinstalling through Windows Update..."
    foreach ($sid in $users) { foreach ($PackageName in $eolPackages) { Remove-Item "$storePath\EndOfLife\$sid\$PackageName" } }

    # Remove AI Package Files
    $appsPath = 'C:\Windows\SystemApps'
    $appsPath2 = 'C:\Program Files\WindowsApps'
    $packagesPath = @()
    foreach ($package in $aipackages) {
        $packagesPath += (Get-ChildItem -Path $appsPath -Directory | Where-Object { $_.FullName -like "*$package*" }).FullName
        $packagesPath += (Get-ChildItem -Path $appsPath2 -Directory | Where-Object { $_.FullName -like "*$package*" }).FullName
    }
    Write-Host "Done!"

    if (!($packagesPath.Length -eq 0 -or $null -eq $packagesPath[0])) {
        Write-Host `n"Uninstalling Copilot components..."
        try {
            Get-InstalledModule -Name RemoveFileZ -ErrorAction Stop
        }
        catch {
            Set-ExecutionPolicy Unrestricted
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201
            Install-Module -Name RemoveFileZ -Force -Confirm:$false
            Import-Module -Name RemoveFileZ
        }

        foreach ($Path in $packagesPath) { Remove-FileZ -Path $Path -Recurse -ErrorAction SilentlyContinue }

        # Clean up module
        Uninstall-Module -Name RemoveFileZ -Confirm:$false
        Remove-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\RemoveFileZ" -Recurse -ErrorAction SilentlyContinue
        Write-Host "Done!"
    }
    else { Write-Host "Done!" }

    # Remove any possible screenshot from Recall
    Remove-Item -Path "$env:LOCALAPPDATA\CoreAIPlatform*" -Recurse
}