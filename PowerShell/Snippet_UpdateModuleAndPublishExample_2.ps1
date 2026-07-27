New-mModuleFromFile -TargetPath '.' -ModuleName mVMwarePowerCLI -Version "2020.02.05" -Files (Get-Content .\__ModuleBuildFiles\mVMwarePowerCLI_FileList.txt) -Author "cmonahan" -CompanyName "companyname" -Description "PowerShell code for managing VMware environments" -ProjectUri 'https://github.monster.com/OPS/mVMwarePowerCLI' -LicenseUri 'https://www.monster.com/inside/terms-of-use'

Publish-Module -Path '__Module\mVMwarePowerCLI\' -NuGetApiKey $NugetApiKey -repository Nugetcompanyname -ReleaseNotes (Get-Content .\__ModuleBuildFiles\mVMwarePowerCLI_ReleaseNotes.txt) -Tags "PowerShell,PowerCLI,VMware"

PS> Publish-Module -Path '__Module\mVMwarePowerCLI\' -NuGetApiKey $NugetApiKey -repository Nugetcompanyname -ReleaseNotes (Get-Content .\__ModuleBuildFiles\mVMwarePowerCLI_ReleaseNotes.txt) -Tags "PowerShell,PowerCLI,VMware"
WARNING: Tags are now supported in the module manifest file (.psd1). Update the module manifest file of module 'mVMwarePowerCLI' in 'D:\OneDrive - companyname_AD\repos\mVMwarePowerCLI\__Module\mVMwarePowerCLI' with the newest tag changes. You can run Update-ModuleManifest -Tags to update the manifest with tags.

WARNING: ReleaseNotes is now supported in the module manifest file (.psd1). Update the module manifest file of module 'mVMwarePowerCLI' in 'D:\OneDrive - companyname_AD\repos\mVMwarePowerCLI\__Module\mVMwarePowerCLI' with
 the newest ReleaseNotes changes. You can run Update-ModuleManifest -ReleaseNotes to update the manifest with ReleaseNotes.

WARNING: This module 'C:\Users\cmonahan\AppData\Local\Temp\4\265860195\mVMwarePowerCLI\mVMwarePowerCLI.psd1' has exported functions. As a best practice, include exported functions in the module manifest file(.psd1). You can run Update-ModuleManifest -FunctionsToExport to update the manifest with ExportedFunctions field.

