<#
.SYNOPSIS
Creates virtual switch in Hyper-V

.PARAMETER Name
Name of the switch

.PARAMETER Type
Type of the switch, choose between internal, external or private
Default value: internal

.PARAMETER NetAdapter
NetAdapter which the switch should be bound to.

.EXAMPLE
Build-LabSwitch -Name "Lab-switch" -Type "external" -NetAdapter "ethernet"

.NOTES
https://docs.microsoft.com/en-us/powershell/module/hyper-v/new-vmswitch?view=win10-ps

#>
function Build-LabSwitch {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]$Name,
        [ValidateSet("internal", "external", "private", ErrorMessage = "Try {1} instead")]
        [String]$Type = "internal",
        [Parameter(Mandatory = $false)]
        [String]$NetAdapter
    )
    BEGIN {
        try {
            if ( Get-VMSwitch | Where-Object { $_.Name -eq $Name } ) {
                throw "Switch $Name already exists"
            }
        }
        catch {
            Write-Warning $_.Exception.Message
            break
            return;
        }
    }
    PROCESS {
        try {
            switch ($Type) {
                "internal" {
                    New-VMSwitch $Name -SwitchType "internal" -EA Stop | Out-Null
                }
                "private" {
                    New-VMSwitch $Name -SwitchType "private" -EA Stop | Out-Null
                }
                "external" {
                    New-VMSwitch $Name -NetAdapterName $NetAdapter -EA Stop | Out-Null
                }
            }
        }
        catch {
            Write-Warning $_.Exception.Message
            break
            return;
        }
    }
    END {
        Write-Verbose "Virtual Switch $Name created"
    }
}

<#
.SYNOPSIS
Creates a virtual machine in Hyper-V

.DESCRIPTION
Creates a virtual machine in Hyper-V with great flexability and little time. 
Post-installation configuration such as network settings and joining the machine to a domain is a possibility.


.PARAMETER Name
Name of the VM

.PARAMETER TemplateVHD
Path of the VHD which to copy for use for the new VM

.PARAMETER Memory
Memory in GB of the VM
Default: 1GB

.PARAMETER Generation
Generation of the VM, 1 or 2
Default: 1

.PARAMETER ProcessorCount
Processor count of the VM
Default: 1

.PARAMETER Path
Path of the VM files
Default: ./labs/

.PARAMETER Switch
Switch to be attached to the VM
Default: None

.PARAMETER IP
IP to be assigned to the VM
Default: None
Requires IP, DefaultGateway, Prefix params

.PARAMETER Prefix
Prefix length to be assigned to the VM
Default: 24
Requires IP, DefaultGateway, DNS params

.PARAMETER DefaultGateway
Default Gateway to be assigned to the VM
Default: None
Requires IP, Prefix, DNS params


.PARAMETER DNS
DNS to be assigned to the VM
Default: None
Requires IP, DefaultGateway, Prefix params

.PARAMETER Username
Username for local administrator account
Default: None
Required for post-installation configuration such as network settings

.PARAMETER Password
Password for local administrator account
Default: None
Required for post-installation configuration such as network settings

.PARAMETER DomainJoined
Whether or not to join the VM to a domain
Default: $false
Requires DomainName param

.PARAMETER DomainName
Domain to join the computer to
Default: None
Requires DomainJoined


.EXAMPLE
Build-LabVM -Name "My-VM" -TemplateVHD "C:\template.vhd" -Memory 2GB -Generation 1 -ProcessorCount 2 -Switch "My-Switch" -IP "192.168.0.2" -Prefix "24" -DefaultGateway "192.168.0.1" -DNS "127.0.0.1" -Username "Administrator" -Password ("Pa55w0rd" | ConvertTo-SecureString -AsPlainText -Force) -DomainJoined $true -DomainName "contoso.local"

.NOTES
https://docs.microsoft.com/en-us/powershell/module/hyper-v/new-vm?view=win10-ps

#>
function Build-LabVM {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]$Name,
        [Parameter(Mandatory = $false)]
        [String]$TemplateVHD,
        [Parameter(Mandatory = $false)]
        [Int64]$Memory = 1GB,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 2)]
        [int16]$Generation = 1,
        [Parameter(Mandatory = $false)]
        [int16]$ProcessorCount = 1,
        [Parameter(Mandatory = $false)]
        [String]$Path = ".\Labs\",
        [Parameter(Mandatory = $false)]
        [String]$Switch,
        [Parameter(Mandatory = $false)]
        [String]$IP,
        [Parameter(Mandatory = $false)]
        [String]$Prefix,
        [Parameter(Mandatory = $false)]
        [String]$DefaultGateway,
        [Parameter(Mandatory = $false)]
        [String]$DNS,
        [Parameter(Mandatory = $false)]
        [String]$Username,
        [Parameter(Mandatory = $false)]
        [SecureString]$Password,
        [Parameter(Mandatory = $false)]
        [bool]$DomainJoined = $false,
        [Parameter(Mandatory = $false)]
        [String]$DomainName
    )
    BEGIN {
        $Credentials = New-Object System.Management.Automation.PSCredential ($Username, $Password)
        ## Fix so it stops if one fails
        try {
            #Uses appropiate file ending
            $ValidateTemplateVHD = Get-VHD -Path $TemplateVHD -EA stop
            $VHDDestination = "$Path\$Name\$Name.$($ValidateTemplateVHD.Vhdformat)"

            if (Get-VM | Where-Object { $_.Name -eq $Name }) {
                throw "Virtual Machine $Name already exists."
            }
            if ( !(Test-Path $Path) ) {
                New-Item -ItemType Directory -Path $Path -EA stop | Out-Null
            }
            if (Test-Path $Path) {
                New-Item -ItemType Directory -Path "$Path/$Name" -EA stop | Out-Null
            }
            if ( ($TemplateVHD) -and (Test-Path $TemplateVHD -EA SilentlyContinue) ) {
                if ( !(Test-Path $VHDDestination -EA stop) ) {
                    Copy-Item $TemplateVHD $VHDDestination -EA stop
                }
                else {
                    throw "VHD already exists in destination path"
                }
                
            }
            else {
                throw "Missing TemplateVHD path $TemplateVHD"
            }
        }
        catch {
            throw $_.Exception.Message
            break
        }
        
    }
    PROCESS {
        ## Build the VM
        try {
            $VMParameters = @{
                Name               = $Name
                MemoryStartupBytes = $Memory
                VHDPath            = $VHDDestination
                Path               = $Path
                Generation         = $Generation
            }

            if ( $PSBoundParameters.ContainsKey('Switch') ) {
                if ( Get-VMSwitch | Where-Object { $_.Name -eq $Switch } ) {
                    $VMParameters.Add('Switch', $Switch)
                }
            }

            $NewVM = New-VM @VMParameters -EA stop
            if ( ($NewVM.ProcessorCount -ne $ProcessorCount) ) {
                $NewVM | Set-VM -ProcessorCount $ProcessorCount -EA stop
            }
        }
        catch {
            throw $_.Exception.Message
            break
        }
        ## Post VM initial installation
        try {
            ## Start the VM
            Start-VM $Name
            ## Wait for VM to start up
            do { Start-Sleep 5 } while ( (Get-VM $Name).state -ne "Running" )

            # Rename computer
            Invoke-Command `
                -VMName $Name `
                -ScriptBlock { param ($NewName) Rename-Computer -ComputerName $env:computername -NewName $NewName -Force } `
                -Credential $Credentials `
                -ArgumentList $Name `
                -EA stop
            Restart-VM $Name -Force -Wait
            # Wait
        

            do { Start-Sleep 5 } while ( (Get-VM $Name).state -ne "Running" )


            ## Final configurations
            $SetupVM = 
            {
                ## Network configuration
                if ( ($Using:IP) -and ($Using:Prefix) -and ($Using:DefaultGateway) -and ($Using:DNS) ) {
                    $IFIndex = (Get-NetAdapter).ifIndex
                    New-NetIPAddress -InterfaceIndex $IFIndex -IPAddress $Using:IP -PrefixLength $Using:Prefix -DefaultGateway $Using:DefaultGateway -EA Stop
                    Set-DNSClientServerAddress –interfaceIndex $IFIndex –ServerAddresses $Using:DNS -EA stop
                }
                if ( $Using:DomainJoined ) {
                    Add-Computer -DomainName $Using:DomainName -ComputerName $env:computername -Credential $Using:Credentials -Restart –Force -EA stop
                }
            }
            Invoke-Command -VMName $Name -ScriptBlock $SetupVM -Credential $Credentials
        }
        catch {
            throw $_.Exception.Message
        }
    }
    END {
        Write-Verbose "Virtual Machine $Name created"
    }
}

<#
.SYNOPSIS
Installs a new AD Forest

.PARAMETER Name
Name of the VM to promote to DC
Default: None

.PARAMETER DomainName
Name of the domain
Default: None

.PARAMETER Username
Username of local administrator
Default: None

.PARAMETER Password
Password of local administrator AND DSRM Password
Default: None

.PARAMETER DomainMode
Domain functional level
Default: "WinThreshold" (WIN2016)

.PARAMETER ForestMode
Forest functional level
Default: "WinThreshold" (WIN2016) 


.EXAMPLE
Build-Forest -Name "My-VM" -DomainName "contoso.local" -Username "Administrator" -Password ("Pa55w0rd" | ConvertTo-SecureString -AsPlainText -Force)

.NOTES
https://docs.microsoft.com/en-us/powershell/module/addsdeployment/install-addsforest?view=win10-ps

#>
function Build-LabForest {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Name,
        [Parameter(Mandatory = $true)]
        [String]$DomainName,
        [Parameter(Mandatory = $true)]
        [String]$Username,
        [Parameter(Mandatory = $true)]
        [SecureString]$Password,
        [Parameter(Mandatory = $false)]
        [String]$DomainMode = "WinThreshold",
        [Parameter(Mandatory = $false)]
        [String]$ForestMode = "WinThreshold"
    )
    $Credentials = New-Object System.Management.Automation.PSCredential ($Username, $Password)
    try {
        if (Get-VM | Where-Object { $_.Name -eq $Name }) {
            $InstallForest = {
                Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
                Import-Module ADDSDeployment
                Install-ADDSForest `
                    -CreateDnsDelegation:$false `
                    -DomainMode $Using:DomainMode `
                    -DomainName $Using:DomainName `
                    -ForestMode $Using:ForestMode `
                    -InstallDns:$true `
                    -SafeModeAdministratorPassword $Using:Credentials.Password `
                    -Force
                ## Do lots of stuff
            }
            Invoke-Command -VMName $Name -ScriptBlock $InstallForest -Credential $Credentials
        }
    }
    catch {
        throw $_.Exception.Message
    }
}

<#
.SYNOPSIS
Deletes Lab VM

.DESCRIPTION
This function, unlike Remove-VM is better integrated with the module and also deletes the VHD associated with the VM

.PARAMETER Name
Name of the VM

.EXAMPLE
Remove-LabVM -Name "My-VM"

.NOTES
Deletes the VHD if in the same folder as the VM

#>
function Remove-LabVM {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String]$Name
    )
    try {
        $VM = Get-VM | Where-Object { $_.Name -eq $Name }
        ## Turns off VM and removes all its data
        if ($VM) {
            $VM | Stop-VM -TurnOff
            do { Start-Sleep 5 } while ( (Get-VM $Name).state -eq "Running" )
            Get-ChildItem -Path $VM.Path -Recurse | Remove-Item -Force -Recurse
            Remove-Item $VM.Path -Force 
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}