function New-mModuleFromFile {

	<#
    .SYNOPSIS
        Build a script module from a list of functions contained in individual ps1 files.

    .DESCRIPTION
        Creates the .psd1 and .psm1 files in subdirectory named for the module name.  The individual function .ps1 files are concatenated into the .psm1 file and the .psd1 file is created using parameter values passed into this function or default values.

	.PARAMETER Tags
		A content tag classifying technologies the module supports.  Helps in searching for modules in repositories, other places.  See the New-ModuleManifest documentation for more details.

	.PARAMETER  TargetPath
        The directory that the module directory will be created in.  If not specified than the current directory will be used.

	.PARAMETER  ModuleName
		The name of the module.  This will be used to make the module's directory, name the .psd1 and .psm1 files, and name the module in the .psd1 file.

	.PARAMETER  Version
		The version of the module in the format of the type System.Version.  See the New-ModuleManifest documentation for more details.
		https://docs.microsoft.com/en-us/dotnet/api/system.version.-ctor?view=netframework-4.7.2
		https://msdn.microsoft.com/en-us/library/system.version(v=vs.110).aspx .
		https://www.powershellmagazine.com/2014/01/03/pstip-validating-version-numbers-without-regex/

	.PARAMETER  Files
		An array of one or more .ps1 function files to be put into the module.  They can be passed as strings, file objects, or anything else as long as PowerShell can find the file(s) you want.

    .PARAMETER Guid
		By default generated with New-Guid, but can be overwritten with a valid Guid when passed as a parameter.  See the New-ModuleManifest documentation for more details.

	.PARAMETER Author
		The module's author.  Defaults to the username in the current shell environment.  See the New-ModuleManifest documentation for more details.

	.PARAMETER CompanyName
		The author's company.  Defaults to $null if not set.  See the New-ModuleManifest documentation for more details.

	.PARAMETER ReleaseNotes
		A multiline text string for the the current version's release notes.  See the New-ModuleManifest documentation for more details.

	.PARAMETER Description
		A short description of the modules scope and functionality.  Defaults to $null if not set.  See the New-ModuleManifest documentation for more details.

	.PARAMETER MinimumRequiredPowerShellVersion
		Defaults to 7.0.0.  See the New-ModuleManifest documentation for more details.

	.PARAMETER ProjectURI
		A link to a location related to the function, such as a Git repo or Wiki page.  See the New-ModuleManifest documentation for more details.

	.PARAMETER LicenseURI
		A link to the software license the code is released under.  See the New-ModuleManifest documentation for more details.

	.PARAMETER ExternalModuleDependencies
		An array of external module dependencies.  See the New-ModuleManifest documentation for more details.

	.PARAMETER ProcessorArchitecture
		The processor architecture of the module.  Defaults to 'None'.  See the New-ModuleManifest documentation for more details.

		.EXAMPLE
        New-mModuleFromFile -TargetPath C:\Temp\ -ModuleName TestModule -Version "1.0.0.0" -Files (Get-Content .\testfiles.txt)

    .NOTES
        For best compatibility and readability inside the .psm1 file the function's comment based help should be placed after the first bracket.  For example:

		function Get-Something {
		< #
			.SYNOPSIS
			blah

			et cetera
		# >  (Note: the space between the <, #, and > characters is so that this section isn't parsed as a real comment.)

			param (stuff)

			code
			code
			code
		}

		Created by:   	cmonahan
		Organization: 	companyname, GTI

#>

	#TODO: Add parameter validation.
	#TODO: Update comment based help.
	#TODO: Update to match PowerShell function template.
	#TODO: Update all output to the standard format using the snippet "OutputMessage".
	#TODO: Add WhatIf support

	[cmdletbinding()]
	param (
		[Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $false)]$TargetPath = (Get-Location),
		[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $false)][System.String]$ModuleName,
		[Parameter(Position = 2, Mandatory = $true, ValueFromPipeline = $false)][System.Version]$Version = $null,
		[Parameter(Position = 3, Mandatory = $true, ValueFromPipeline = $false)]$Files,
		[Parameter(Position = 4, Mandatory = $false, ValueFromPipeline = $false)]$Guid = (New-Guid),
		[Parameter(Position = 5, Mandatory = $false, ValueFromPipeline = $false)]$ExternalModuleDependencies = $null,
		[Parameter(Position = 6, Mandatory = $false, ValueFromPipeline = $false)][System.String]$Author = $env:USERNAME,
		[Parameter(Position = 7, Mandatory = $true, ValueFromPipeline = $false)][System.String]$CompanyName,
		[Parameter(Position = 8, Mandatory = $true, ValueFromPipeline = $false)][System.String]$Description,
		[Parameter(Position = 9, Mandatory = $true, ValueFromPipeline = $false)][System.String]$Tags = $null,
		[Parameter(Position = 10, Mandatory = $false, ValueFromPipeline = $false)][System.Version]$MinimumRequiredPowerShellVersion = [System.Version]"7.0.0",
		[Parameter(Position = 11, Mandatory = $true, ValueFromPipeline = $false)][System.String]$ReleaseNotes,
		[Parameter(Position = 12, Mandatory = $true, ValueFromPipeline = $false)][System.Uri]$ProjectUri,
		[Parameter(Position = 13, Mandatory = $true, ValueFromPipeline = $false)][System.Uri]$LicenseUri,
		[Parameter(Position = 14, Mandatory = $false, ValueFromPipeline = $false)][System.String]$ProcessorArchitecture = 'None'
	)

	#TODO: Don't use "#Requires -RunAsAdministrator".  It requires the session to be run as Administrator to even load the module.  Change to a code test to make sure this function is running in an Administrator session.
	# #Requires -Module mPowerShellGenerics,mWindowsGeneral

	#TODO: Add support to use a configuration file for the routine parameters that don't change from build to build.  Everything but the version?

	begin {

		# The function Get-mCurrentLine is used in every script and function.
		if (Test-Path -Path function:\Get-mCurrentLine) { Write-Verbose "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function Get-mCurrentLine is loaded in the session." }
		else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - Line 52 or so - Function Get-mCurrentLine is not loaded in the session." }

		Write-Verbose "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function started."

		# Test for required modules.  Internal support modules and vendor specific technology modules in addition to the builtin Microsoft PowerShell modules.  Remove this section if it's not needed.
		$ModuleList = "mPowerShellGenerics"
		$ModuleList | ForEach-Object {
			if (Test-mIsModuleLoaded -Name $_) { Write-Verbose "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is loaded in the session." }
			else { throw "$(Get-mNow)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is not loaded in the session." }
		}

	} # end begin block

	# ======================================================================================

	process {
		# Validate inputs
		if (-not (Test-Path -Path $TargetPath)) {
			Write-Output "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** TargetPath not valid.  Aborting."
			break
		}

		# Due to a bug/oddity files on network drives must be in UNC format.
		if (Test-mIsDriveLetterMapped -DriveLetter ($TargetPath.Substring(0, 1))) {
			Write-Output "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** TargetPath is a drive letter mapped to a network share.  Due to a bug/oddity files on network drives must be in UNC format."
			break
		}

		$Files | ForEach-Object {
			Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** File string is: $($_)"
			if (-not (Test-Path -Path $_)) {
				Get-ChildItem $_
				Test-Path -Path $_
				Write-Output "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** File not found: $($_) - Aborting."
				break
			}
		}

		if ( ($null -eq $Description) -or ($Description -eq "") ) {
			Write-Output "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Parameter Description is null or empty.  Aborting."
			break
		}

		Write-Verbose -Message "$(Get-mCurrentLine)"

		if ( Test-Path -Path "$($TargetPath)\__Module\$($ModuleName)" ) {
			Write-Output "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** Module directory already exists: $($TargetPath)\__Module\$($ModuleName) - Aborting."
			break
		}
		else {
			$ModuleDirectory = "$($TargetPath)\__Module\$($ModuleName)"
			$PSM1file = "$($ModuleName).psm1"
			$PSM1fileFullPath = "$($TargetPath)\__Module\$($ModuleName)\$($ModuleName).psm1"
			$PSD1file = "$($ModuleName).psd1"
			$PSD1fileFullPath = "$($TargetPath)\__Module\$($ModuleName)\$($ModuleName).psd1"
		}

		Write-Verbose -Message "$(Get-mCurrentLine)"
		Write-Verbose -Message "TargetPath-`t$($TargetPath)`nModuleName-`t$($ModuleName)`nModuleDirectory-`t	$($ModuleDirectory)`nPSM1file-`t$($PSM1file)`nPSM1fileFullPath-`t$($PSM1fileFullPath)`nPSD1file-`t$($PSD1file)`nPSD1fileFullPath-`t$($PSD1fileFullPath)`n`n"

		if (-not (Test-Path $ModuleDirectory)) { mkdir $ModuleDirectory }

		# Create PSM1 files
		Write-Verbose -Message "$(Get-mCurrentLine)"
		Write-Verbose -Message "$($Files)"
		$Files | ForEach-Object { Get-Content $_ }

		Write-Verbose -Message "$(Get-mCurrentLine)"
		if (-not (test-path $PSM1fileFullPath)) {
			#TODO: Add some sort of overwrite or abort logic if the PSM1 file already exists
			$Files | ForEach-Object {
				Write-Verbose -Message "$(Get-mCurrentLine)"
				Write-Verbose -Message "$(Get-Content -Path $_)"
				Add-Content -Value (Get-Content -Path "$($_)") -Path $PSM1fileFullPath
			}
			Write-Verbose -Message "$(Get-mCurrentLine)"
			Write-Verbose -Message "$(Get-ChildItem $PSM1fileFullPath)"
		}
		else { Write-Output "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** errmsg $(Get-mCurrentLine) create psm1 $(Get-ChildItem $PSM1fileFullPath)" }

		Write-Verbose -Message "$(Get-mCurrentLine)"

		# Create PSD1 file
		#todo: Set value of $Version- 1) user entered as parameter, 2) incremement from current module version, 3) set to 0.0.0.1

		Write-Verbose -Message "$(Get-mCurrentLine)"

		#TODO: Research if this is needed anymore.
		if (test-path $PSM1fileFullPath) {
			<# if (Test-Path -Path "$($TargetPath)\$($ModuleName)_ChangeLog.csv") {
				# If the changelog CSV file exists copy it to the module directory.
				Copy-Item -Path "$($TargetPath)\$($ModuleName)_ChangeLog.csv" -Destination $ModuleDirectory
			}
			if (Test-Path -Path "$($TargetPath)\$($ModuleName)_ReleaseNotes.csv") {
				# If the rele file exists copy it to the module directory.
				Copy-Item -Path "$($TargetPath)\$($ModuleName)_ReleaseNotes.csv" -Destination $ModuleDirectory
			} #>
			Write-Verbose -Message "$(Get-Date)- $(Get-mCurrentLine) *** Creating the psd1 file $($PSD1fileFullPath)"
			#TODO: Fix error when specifying a GUID.  "New-mModuleFromFile: Cannot process argument transformation on parameter 'Guid'. Cannot convert the "System.Object[]" value of type "System.Object[]" to type "System.Guid"."
			#			New-ModuleManifest -Path $PSD1fileFullPath -RootModule $PSM1file -Guid $Guid -Author $Author -CompanyName $CompanyName -ModuleVersion $Version -Description $Description -Tags $Tags -ProcessorArchitecture None -PowerShellVersion $MinimumRequiredPowerShellVersion -ReleaseNotes $ReleaseNotes -ProjectUri $ProjectUri -LicenseUri $LicenseUri
			New-ModuleManifest -Path $PSD1fileFullPath `
				-Guid $Guid `
				-RootModule $PSM1file `
				-Author $Author `
				-CompanyName $CompanyName `
				-ModuleVersion $Version `
				-Description $Description `
				-Tags $Tags `
				-ProcessorArchitecture $ProcessorArchitecture `
				-PowerShellVersion $MinimumRequiredPowerShellVersion `
				-ReleaseNotes $ReleaseNotes `
				-ProjectUri $ProjectUri `
				-LicenseUri $LicenseUri
			if ($VerbosePreference -ne 'SilentlyContinue') { Get-ChildItem $ModuleDirectory }
		}
		else { Write-Output "$(Get-Date)- $($MyInvocation.InvocationName) Line $(Get-mCurrentLine) *** No psm1 file" }

		# Test module
		Test-ModuleManifest -Path $PSD1fileFullPath
		Write-Verbose -Message "$(Get-mCurrentLine)"

	} #end of the process block

	end {

		Remove-Variable TargetPath, ModuleName, Version, Files, Guid, Author, CompanyName, Tags, Description, MinimumRequiredPowerShellVersion, ProjectUri, LicenseUri, PSM1file, PSM1fileFullPath, ModuleDirectory, PSD1fileFullPath, PSD1file, ReleaseNotes, ExternalModuleDependencies, ProcessorArchitecture -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup

	} #end of the end block

} # end function
