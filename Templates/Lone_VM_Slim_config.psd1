########################################################################
##
## This file is for configuring and creating a test environment
##
########################################################################

#The objects are created in the same order as placed in this file
#ActionType represents the function to be used. See acceptable values below
#"Switch" for New-LabSwitch
#"VM" for New-LabVM
#"Forest" for Install-LabForest


@{
    Configuration = @(
        @{
        ModulePath = ".\LabModule\LabModule.psm1"
        }
    )

    ActionList = @(
        #VM
        @{
            ActionType = "VM"
            Name = "Lab-SRV1"
            TemplateVHD = ".\template.vhd"
        }
    )
}