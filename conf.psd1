#The objects are created in the same order as placed in this file
#ActionType represents the function to be used. See acceptable values below
#"Switch" for Build-LabSwitch
#"VM" for Build-LabVM
#"Forest" for Build-LabForest


@{
    ActionList = @(
        #Switch
        @{
            ActionType = "Switch"
            Name = "Lab-Switch"
            Type = "internal"
            NetAdapter = "Ethernet"
         }
         #VM
         @{
            ActionType = "VM"
            Name = "Lab-DC"
            TemplateVHD = "C:\Users\Sebastian\Documents\GitHub\Exjobb\TMP\template.vhd"
            Switch = "Lab-Switch"
        
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

            #User settings
            Username = "Administrator"
            Password = "Pa55w0rd"
         }
         #New Forest
         @{
             ActionType = "Forest"
             Name = "Lab-DC"
             DomainName = "contoso.lab"
             NetBIOS = "contoso"
             DomainMode = "WinThreshold"
             ForestMode = "WinThreshold"

            #User settings
            Username = "Administrator"
            Password = "Pa55w0rd"
        }
        #VM
        @{
            ActionType = "VM"
            Name = "Lab-SRV1"
            TemplateVHD = "C:\Users\Sebastian\Documents\GitHub\Exjobb\TMP\template.vhd"
        
            #Network settings
            Switch = "Lab-Switch"
            IP = "10.0.0.2"
            Prefix = "24"
            DefaultGateway = "10.0.0.1"
            DNS = "10.0.0.1"
        
            # Specs
            Memory = 2GB
            Generation = 1
            ProcessorCount = 2
            Path = ".\Labs\"

            #User settings
            Username = "Administrator"
            Password = "Pa55w0rd"
        
            #This VM will be joined to domain $DomainName
            DomainJoined = $true
            DomainName = "contoso.lab"
        }
    )
}