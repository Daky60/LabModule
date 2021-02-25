if (Get-Module | Where-Object{$_.Name -eq "LabModule"}) {
    Remove-Module LabModule
}
Import-Module .\LabModule.psm1

#Get-Content .\config.psd1
$config = Import-PowerShellDataFile .\config.psd1
Write-Host($config.AllNodes)

#Build-LabSwitch -Name "$labSuffix-Switch" -Type $SwitchType
#Build-LabVM @VM_DC -Username $User -Password $Pass
#Build-Forest @Forest -Username $User -Password $Pass
#Build-LabVM @VM_SRV1 -Username $User -Password $Pass

if (Get-Module | Where-Object{$_.Name -eq "LabModule"}) {
    Remove-Module LabModule
}