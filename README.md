# LabModule
A Powershell module for easy deployment of test environments in Hyper-V.  
The purpose of the module is to limit time spent building test environments.  
With this module you can create virtual switches, VMs, domains and join said VMs to it, among other things with just one button.  

---
## Requirements
* Copy of Windows Server in VHD format (to be used as a template)  
  > https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server  

* Powershell version 5.1 or above  

* Administrative privileges  

* Hyper-V


---

## Instructions

1. Download a VHD copy of Windows Server and ideally place it in this folder.  
2. Create a VM and run through the installation process manually for the VHD.  
   > Import-Module ".\LabModule.psm1"  
   > Build-LabVM -Name "Template" -TemplateVHD ".\lab_img.vhd"  

   This will create a VM called Template with a VHD called Template.VHD  

3. When you're finished you can either turn the machine off or sysprep it.  
   (If you intend to create a domain for example, you need to sysprep to avoid SID conflicts)
   * Create a folder under C:\ called sysprep and then a sysprep.xml file inside that folder
   * Copy the contents from sysprep.xml onto the newly created sysprep.xml
   * Open an elevated command prompt and run the following to initiate Sysprep
     > %WINDIR%\system32\sysprep\sysprep.exe /generalize /shutdown /oobe /mode:vm /unattend:C:\sysprep\sysprep.xml
   * Once done, the machine will have turned off. See next step to proceed.
4.  Once the machine is completely off, it's important to merge the VHD with its most recent checkpoint, if you have any.  
    * Open Hyper-V and click on Edit Disk. Search for the latest avhd or avhdx file associated with our newly created Template.VHD  
    * Click next and click on Merge and then choose to merge it to Template.VHD  
5. You can now import the module and use as is, or edit the config.psd1 file and make a more comprehensive test environment  
   * Read through config.psd1 and make any changes you would like. 
   * See LabModule.psm1 or use Get-Help on any command for more documentation if unsure.
6. When you are satisfied with your config.psd1 file, run init.ps1 to create your lab environment.

---

## LabModule.psm1

This file is the module itself and holds most of the functionality, but also documentation.  
Read through this file if you require any help.


---

## config.psd1

This file is used to configure a more comprehensive test environment and to be paired with init.ps1

---

## init.ps1

This file reads config.psd1 and creates the test environment

---

