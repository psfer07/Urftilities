if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 1
}
Import-Module -DisableNameChecking "$PSScriptRoot\..\modules\titles.psm1"

Write-Step "Improving performance"
Write-Host "--> Optimizing timer resolution..."
Write-Host "`nSetting System Timer Resolution to 5 microseconds..."

$ntqtrmin = $null
$ntqtrmax = $null
$ntqtrcur = $null

$ntdesiredres = 5000
$ntsetres = $true
$ntcurrentres = 156250

$MethodDefinition = @'
[DllImport("ntdll.dll", SetLastError=true)]
public static extern NtStatus NtQueryTimerResolution(out uint MinimumResolution, out uint MaximumResolution, out uint ActualResolution);

[DllImport("ntdll.dll", SetLastError=true)]
public static extern int NtSetTimerResolution(int DesiredResolution, bool SetResolution, out int CurrentResolution );
'@
$NtStatus = Add-Type -MemberDefinition $MethodDefinition -Name 'NtStatus' -Namespace 'Win32' -PassThru

$ret1 = [Win32.NtStatus]::NtSetTimerResolution($ntdesiredres, $ntsetres, [ref]$ntcurrentres)

[Win32.NtStatus]::NtQueryTimerResolution([ref]$ntqtrmin, [ref]$ntqtrmax, [ref]$ntqtrcur)

Write-Host "Done!"
