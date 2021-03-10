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
        }
    )
}