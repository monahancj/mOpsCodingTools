$NugetApiKey = '9148d650-5b06-4b5b-a65c-40d315e1bc4a'

-----------------------
# Replace the module name with the module you are working with.

New-mModuleFromFile -TargetPath '.' -ModuleName mPowerShellGenerics -Version "2021.3.2.0" -Files (Get-Content .\__ModuleBuildFiles\mPowerShellGenerics_FileList.txt) -Author "cmonahan" -CompanyName "companyname" -Description "Mostly small helper functions to be used in other functions." -ReleaseNotes (Get-Content .\__ModuleBuildFiles\mPowerShellGenerics_ReleaseNotes_v2021.08.23.0.txt) -ProjectUri 'https://github.com/monster-next/mPowerShellGenerics' -LicenseUri 'https://www.monster.com/inside/terms-of-use'

Publish-Module -Path '__Module\mPowerShellGenerics\' -NuGetApiKey $NugetApiKey -repository Nugetcompanyname -ReleaseNotes (Get-Content .\__ModuleBuildFiles\mPowerShellGenerics_ReleaseNotes_v2021.08.23.0.txt) -Tags "PowerShell" -WhatIf

-----------------------
# Replace the module name with the module you are working with.

git log --pretty=format:"%ad%x09%an%x09%s" --after ((Get-Module -Name mWindowsGeneral).Version -replace("\.","-"))

New-mModuleFromFile -TargetPath '.' -ModuleName mWindowsGeneral -Version "2021.8.24.0" -Files (Get-Content .\__ModuleBuildFiles\mWindowsGeneral_FileList.txt) -Author "cmonahan" -CompanyName "companyname" -Description "PowerShell code for managing Microsoft Windows environments" -ReleaseNotes (Get-Content .\__ModuleBuildFiles\mWindowsGeneral_ReleaseNotes_v2021.08.24.0.txt) -ProjectUri 'https://github.com/monster-next/mWindowsGeneral' -LicenseUri 'https://www.monster.com/inside/terms-of-use'

Publish-Module -Path '__Module\mWindowsGeneral\' -NuGetApiKey $NugetApiKey -repository Nugetcompanyname -ReleaseNotes (Get-Content .\__ModuleBuildFiles\mWindowsGeneral_ReleaseNotes_v2021.08.24.0.txt) -Tags "PowerShell, Microsoft, Windows" -WhatIf

-----------------------
# Replace the module name with the module you are working with.

git log --pretty=format:"%ad%x09%an%x09%s" --after ((Get-Module -Name mVMwarePowerCLI).Version -replace("\.","-"))

ipcsv .\__ModuleBuildFiles\_ChangeLog_mVMwarePowerCLI.csv | ? { ( ((Get-Date $_.Date) -gt (Get-Date "2/28/2021")) -AND ((Get-Date $_.Date) -lt (Get-Date).AddDays(1)) )} | select Version,@{n='Date';e={Get-Date -Date $_.Date -UFormat %Y-%m-%d }},Cmdlet,type,Headline,Notes | sort Version,Cmdlet,Type,Date | Format-Table -AutoSize -Property * -Force | Out-File -FilePath .\__ModuleBuildFiles\mVMwarePowerCLI_ReleaseNotes_v2021.08.25.0.txt -Width 500

New-mModuleFromFile -TargetPath '.' -ModuleName mVMwarePowerCLI -Version "2021.8.25.0" -Files (Get-Content .\__ModuleBuildFiles\mVMwarePowerCLI_FileList.txt) -Author "cmonahan" -CompanyName "companyname" -Description "PowerShell code for managing VMware environments" -Tags "PowerShell, VMware, PowerCLI"  -ReleaseNotes "$(Get-Content .\__ModuleBuildFiles\mVMwarePowerCLI_ReleaseNotes_v2021.08.25.0.txt)" -ProjectUri 'https://github.com/monster-next/mVMwarePowerCLI' -LicenseUri 'https://www.monster.com/inside/terms-of-use'

Publish-Module -Path '__Module\mVMwarePowerCLI\' -NuGetApiKey $NugetApiKey -Repository Nugetcompanyname -WhatIf

-----------------------
# Replace the module name with the module you are working with.

# Make the release file
ipcsv .\__ModuleBuildFiles\_ChangeLog_mCiscoUcsPowerTool.csv | ? { ( ((Get-Date $_.Date) -gt (Get-Date "6/4/2019")) -AND ((Get-Date $_.Date) -lt (Get-Date).AddDays(1)) )} | Format-Table -AutoSize -Property * -Force | Out-File -FilePath .\__ModuleBuildFiles\mCiscoUcsPowerTool_ReleaseNotes_v2021.08.24.0.txt -Width 500

New-mModuleFromFile -TargetPath '.' -ModuleName mCiscoUcsPowerTool -Version "2021.8.24.0" -Files (Get-Content .\__ModuleBuildFiles\mCiscoUcsPowerTool_FileList.txt) -Author "cmonahan" -CompanyName "companyname" -Description "PowerShell code for managing VMware environments" -Tags "PowerShell, Cisco, UCS, PowerTool"  -ReleaseNotes "$(Get-Content .\__ModuleBuildFiles\mCiscoUcsPowerTool_ReleaseNotes_v2021.08.24.0.txt)" -ProjectUri 'https://github.com/monster-next/mCiscoUcsPowerTool' -LicenseUri 'https://www.monster.com/inside/terms-of-use'

Publish-Module -Path '__Module\mCiscoUcsPowerTool\' -NuGetApiKey $NugetApiKey -repository Nugetcompanyname -ReleaseNotes (Get-Content .\__ModuleBuildFiles\mCiscoUcsPowerTool_ReleaseNotes_v2021.08.24.0.txt) -WhatIf

