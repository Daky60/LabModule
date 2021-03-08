$config = ".\secretconf.psd1"


$Time = Get-Date
try {
    if (Test-Path $config) {
        $config = Import-PowerShellDataFile $config
    }
    else {
        throw "Config file not found. Edit init.ps1"
    }
    if (!(Test-Path $config.Configuration.ModulePath)) {
        throw "Module file not found. Edit config.ps1"
    }
    if (Get-Module | Where-Object { $_.Name -eq "LabModule" }) {
        Remove-Module LabModule
    }
    Import-Module $config.Configuration.ModulePath
}
catch {
    throw
}


try {
    foreach ($i in $config.ActionList) {
        $StartTime = Get-Date
        if ($i.Password) {
            $i.Password = $i.Password | ConvertTo-SecureString -AsPlainText -Force
        }
        if ($i.ActionType) {
            switch ($i.ActionType) {
                "Switch" {
                    $i.Remove("ActionType")
                    New-LabSwitch @i
                    if ($?) {
                        $TimeElapsed = $(Get-Date) - $StartTime
                        Write-Host("Switch $($i.Name) created in $([math]::Round($TimeElapsed.TotalMinutes)) minutes")
                    }
                }
                "VM" {
                    $i.Remove("ActionType")
                    New-LabVM @i
                    if ($?) {
                        $TimeElapsed = $(Get-Date) - $StartTime
                        Write-Host("VM $($i.Name) created in $([math]::Round($TimeElapsed.TotalMinutes)) minutes")
                    }
                }
                "Forest" {
                    $i.Remove("ActionType")
                    Install-LabForest @i
                    if ($?) {
                        $TimeElapsed = $(Get-Date) - $StartTime
                        Write-Host("Forest $($i.DomainName) created in $([math]::Round($TimeElapsed.TotalMinutes)) minutes")
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


$TimeElapsed = $(Get-Date) - $Time
Write-Host("Total time elapsed: $([math]::Round($TimeElapsed.TotalMinutes)) minutes")