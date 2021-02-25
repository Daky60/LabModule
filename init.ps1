$config = ".\conf.psd1"
$module = ".\LabModule.psm1"


if (Get-Module | Where-Object{$_.Name -eq "LabModule"}) {
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
        if ($i.ActionType) {
            switch ($i.ActionType) {
                "Switch" {
                    $i.Remove("ActionType")
                    Build-LabSwitch @i
                }
                "VM" {
                    $i.Remove("ActionType")
                    Build-LabVM @i
                }
                "Forest" {
                    $i.Remove("ActionType")
                    Build-LabForest @i
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
    throw $_.Exception.Message
}


if (Get-Module | Where-Object{$_.Name -eq "LabModule"}) {
    Remove-Module LabModule
}