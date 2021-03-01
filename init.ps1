$config = ".\secretconf.psd1"
$module = ".\LabModule.psm1"


if (Get-Module | Where-Object { $_.Name -eq "LabModule" }) {
    Remove-Module LabModule
}
Import-Module $module


try {
    if (!(Test-Path $module)) {
        throw "Module file not found. Edit init.ps1"
    }
    if (Test-Path $config) {
        $config = Import-PowerShellDataFile $config
    }
    else {
        throw "Config file not found. Edit init.ps1"
    }
    foreach ($i in $config.ActionList) {
        $StartTime = Get-Date
        if ($i.Password) {
            $i.Password = $i.Password | ConvertTo-SecureString -AsPlainText -Force
        }
        if ($i.ActionType) {
            switch ($i.ActionType) {
                "Switch" {
                    $i.Remove("ActionType")
                    Build-LabSwitch @i
                    if ($?) {
                        $TimeElapsed = $(Get-Date) - $StartTime
                        Write-Host("Switch $($i.Name) created in $($TimeElapsed.TotalMinutes) minutes")
                    }
                }
                "VM" {
                    $i.Remove("ActionType")
                    Build-LabVM @i
                    if ($?) {
                        $TimeElapsed = $(Get-Date) - $StartTime
                        Write-Host("VM $($i.Name) created in $($TimeElapsed.TotalMinutes) minutes")
                    }
                }
                "Forest" {
                    $i.Remove("ActionType")
                    Build-LabForest @i
                    if ($?) {
                        $TimeElapsed = $(Get-Date) - $StartTime
                        Write-Host("Forest $($i.DomainName) created in $($TimeElapsed.TotalMinutes) minutes")
                    }
                }
                default { "ActionType must be Switch, VM or Forest" }
            }
        }
        else {
            throw "Missing ActionType. Edit config file"
        }
    }
}
catch {
    throw
}


if (Get-Module | Where-Object { $_.Name -eq "LabModule" }) {
    Remove-Module LabModule
}


$TimeElapsed = Get-Date - $StartTime
Write-Host("Total time elapsed: $($TimeElapsed.TotalMinutes) minutes")