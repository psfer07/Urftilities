# Reused function Write-Title from https://github.com/psfer07/App-DL
function Write-Step {
    param([Parameter(Mandatory, Position = 0)][string]$text)
    if ($text.Length % 2 -ne 0, 1) { [string]$extra = 'o' }
    $b = "o" * (4 + $text.Length)
    Write-Host "`n`nooo$b$extra"
    Write-Host "oo$extra " -NoNewline
    Write-Host "$text" -NoNewline
    Write-Host " oo$extra"
    Write-Host "ooo$b$extra"
}