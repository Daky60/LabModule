$Suffix = "lab"
$User = "Administrator"
$Pass = 'Pa$$w0rd'
$Domain = "contoso"
$ServerTemplate = "C:\Users\Sebastian\Documents\GitHub\Exjobb\TMP\template.vhd"

$Switch = @{
    Name = "Lab-Switch"
    Type = "internal"
    NetAdapter = "Ethernet"
}

$Forest = @{
    Name = "$Suffix-DC"
    DomainName = "$Domain.$Suffix"
    NetBIOS = $Domain
    DomainMode = "WinThreshold"
    ForestMode = "WinThreshold"
}

$VM_DC = @{
    Name = "$Suffix-DC"
    TemplateVHD = $ServerTemplate
    Switch = "$Suffix-Switch"

    #Network settings
    IP = "10.0.0.1"
    Prefix = "24"
    DefaultGateway = "10.0.0.1"
    DNS = "127.0.0.1"

    #Specs
    Memory = 2GB
    Generation = 1
    ProcessorCount = 2
    Path = ".\Labs\"
}

$VM_SRV1 = @{
    Name = "$Suffix-SRV1"
    TemplateVHD = $ServerTemplate

    #Network settings
    Switch = "$Suffix-Switch"
    IP = "10.0.0.2"
    Prefix = "24"
    DefaultGateway = "10.0.0.1"
    DNS = "10.0.0.1"

    # Specs
    Memory = 2GB
    Generation = 1
    ProcessorCount = 2
    Path = ".\Labs\"

    #This VM will be joined to domain $DomainName
    DomainJoined = $true
    DomainName = $Domain
}     
