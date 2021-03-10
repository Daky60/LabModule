########################################################################
##
## This file is for configuring and creating a test environment
##
########################################################################

#The objects are created in the same order as placed in this file
#ActionType represents the function to be used. See acceptable values below
#"Switch" for Build-LabSwitch
#"VM" for Build-LabVM
#"Forest" for Build-LabForest


@{
    Configuration = @(
        @{
        ModulePath = ".\LabModule\LabModule"
        }
    )

    ActionList = @(
        #VM
        @{
            ActionType = "VM"
            Name = "Lab-SRV1"
            TemplateVHD = ".\template.vhd"

            #User settings
            Username = "Administrator"
            Password = "Pa55w0rd"

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
        }
    )
}