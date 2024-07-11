# Make easier the large-scale registry modifications. By psfer07
function Set-RegistryItem {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)][string[]]$Path,
        [Parameter(Position = 1, Mandatory)][string[]]$Name,
        [Parameter(Position = 2, Mandatory)][Object[]]$Value,
        [Parameter(Position = 3)][string[]]$Type = @("DWord")
    )

    if ($Path.Length -gt 1) {
        if ($Value.Length -eq 1 -and $Type.Length -eq 1) {
            foreach ($keyPath in $Path) {
                # Check if the path exists, creates it if not
                if (!(Test-Path $keyPath)) { New-Item -Path $keyPath -Force | Out-Null }
                foreach ($keyName in $Name) {
                    # Check if the key exists, creates it if not
                    if (!(Test-Path "$keyPath\$keyName")) { New-Item -Path "$keyPath\$keyName" -Force | Out-Null }
                    Set-ItemProperty -Path $keyPath -Name $keyName -Value $Value -Type $Type -ErrorAction SilentlyContinue
                }
            }
        }
        else {
            Write-Warning "Error: Don't let more than one path if you want to apply multiple values or types. Use another line instead!"
            return
        }
    }
    elseif ($Path.Length -eq 1) {
        if ($Name.Length -eq $Value.Length -and $Value.Length -eq $Type.Length) {
            for ($i = 0; $i -lt $Value.Length; $i++) {
                Set-ItemProperty -Path $Path -Name $Name[$i] -Value $Value[$i] -Type $Type[$i] -ErrorAction SilentlyContinue
            }
            Pause
            Write-Host "--> Path provided: " $Path
            Write-Host "--> Names provided: " $Name
            Write-Host "--> Values provided: " $Value
            Write-Host "--> Types provided: " $Type
        }
        elseif ($Name.Length -eq $Value.Length -and $Type.Length -eq 1) {
            for ($i = 0; $i -lt $Value.Length; $i++) {
                Set-ItemProperty -Path $Path -Name $Name[$i] -Value $Value[$i] -Type $Type -ErrorAction SilentlyContinue
            }
            Pause
            Write-Host "--> Path provided: " $Path
            Write-Host "--> Names provided: " $Name
            Write-Host "--> Values provided: " $Value
            Write-Host "--> Types provided: " $Type
        }
        elseif ($Name.Length -eq $Type.Length -and $Type.Length -eq 1) {
            foreach ($i in $Value) {
                Set-ItemProperty -Path $Path -Name $Name -Value $i -Type $Type -ErrorAction SilentlyContinue
            }
            Pause
            Write-Host "--> Path provided: " $Path
            Write-Host "--> Names provided: " $Name
            Write-Host "--> Values provided: " $Value
            Write-Host "--> Types provided: " $Type
        }
        elseif ($Value.Length -eq $Type.Length -and $Type.Length -eq 1) {
            foreach ($i in $Name) {
                Set-ItemProperty -Path $Path -Name $i -Value $Value -Type $Type -ErrorAction SilentlyContinue
            }
            Pause
            Write-Host "--> Path provided: " $Path
            Write-Host "--> Names provided: " $Name.GetType().FullName
            Write-Host "--> Values provided: " $Value.GetType().FullName
            Write-Host "--> Types provided: " $Type
        }
        else {
            Write-Warning "Error: Mismatch between lengths of Name, Value, and Type arrays."
            Write-Host "Detailed bad usage:"
            Write-Host "--> Number of names provided: " $Name.Length
            Write-Host "--> Number of values provided: " $Value.Length
            Write-Host "--> Number of types provided: " $Type.Length
            Pause
            Write-Host "--> Path provided: " $Path
            Write-Host "--> Names provided: " $Name
            Write-Host "--> Values provided: " $Value
            Write-Host "--> Types provided: " $Type
            Pause
        }
    }
}
