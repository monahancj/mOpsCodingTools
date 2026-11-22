function New-mModuleFromFile {
	<#
    .SYNOPSIS
        Creates a PowerShell module from a list of function files.

    .DESCRIPTION
        This function reads a list of function files from a text file, embeds them into a PSM1 file,
        generates a changelog from Git history, and creates a module manifest using New-ModuleManifest.

    .PARAMETER SourcePath
        The source directory path containing the function files and module build files.

    .PARAMETER ModuleName
        The name of the module to create.

    .PARAMETER OutputPath
        The output directory path where the module will be created. Default is "__Module\ModuleName" relative to SourcePath.

    .PARAMETER FileListPath
        The path to the text file containing the list of function files to include. Default is "__ModuleBuildFiles\ModuleName_FileList.txt".

    .PARAMETER GitStartDate
        The start date for Git history to generate changelog. Default is "5/1/2024".

    .PARAMETER ModuleVersion
        The version of the module. If not specified, it will be extracted from the latest release notes file.

    .PARAMETER Author
        The author of the module. Default is extracted from git config or "Unknown".

    .PARAMETER ProjectUri
        The project URI for the module. Default is extracted from a placeholder or not set.

    .PARAMETER LicenseUri
        The license URI for the module. Default is "https://opensource.org/license/mit".

    .PARAMETER Description
        The description of the module. If not specified, it will be generated from function help.

    .EXAMPLE
        New-mModuleFromFile -SourcePath "D:\repos\mMyModule" -ModuleName "mMyModule"

    .EXAMPLE
        New-mModuleFromFile -SourcePath "D:\repos\mMyModule" -ModuleName "mMyModule" -OutputPath "D:\Output\Modules\mMyModule" -GitStartDate "1/1/2023"

    .NOTES
        The function requires Git to be installed and accessible in the PATH.
        The function requires the function files to have proper PowerShell function syntax.

    .LINK
        https://github.com/monahancj/mCiscoUcsPowerTool
#>

	[cmdletbinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $false)]
		[string]$SourcePath,

		[Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $false)]
		[string]$ModuleName,

		[Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $false)]
		[string]$OutputPath,

		[Parameter(Position = 3, Mandatory = $false, ValueFromPipeline = $false)]
		[string]$FileListPath,

		[Parameter(Position = 4, Mandatory = $false, ValueFromPipeline = $false)]
		[string]$GitStartDate = "5/1/2024",

		[Parameter(Position = 5, Mandatory = $false, ValueFromPipeline = $false)]
		[string]$ModuleVersion,

		[Parameter(Position = 6, Mandatory = $false, ValueFromPipeline = $false)]
		[string]$Author,

		[Parameter(Position = 7, Mandatory = $false, ValueFromPipeline = $false)]
		[string]$ProjectUri,

		[Parameter(Position = 8, Mandatory = $false, ValueFromPipeline = $false)]
		[string]$LicenseUri = "https://opensource.org/license/mit",

		[Parameter(Position = 9, Mandatory = $false, ValueFromPipeline = $false)]
		[string]$Description
	)

	begin {
		Write-Verbose -Message "New-mModuleFromFile - Starting module creation process"

		# Validate SourcePath
		if (-not (Test-Path -Path $SourcePath)) {
			throw "SourcePath '$SourcePath' does not exist."
		}

		# Set default paths
		if ([string]::IsNullOrWhiteSpace($FileListPath)) {
			$FileListPath = Join-Path -Path $SourcePath -ChildPath "__ModuleBuildFiles\$($ModuleName)_FileList.txt"
		}

		if ([string]::IsNullOrWhiteSpace($OutputPath)) {
			$OutputPath = Join-Path -Path $SourcePath -ChildPath "__Module\$ModuleName"
		}

		# Create output directory if it doesn't exist
		if (-not (Test-Path -Path $OutputPath)) {
			Write-Verbose -Message "Creating output directory: $OutputPath"
			New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
		}

		# Validate FileListPath
		if (-not (Test-Path -Path $FileListPath)) {
			throw "FileListPath '$FileListPath' does not exist."
		}
	}

	process {
		Write-Verbose -Message "Reading file list from: $FileListPath"
		$FileList = Get-Content -Path $FileListPath

		if ($FileList.Count -eq 0) {
			throw "File list is empty."
		}

		Write-Verbose -Message "Found $($FileList.Count) files to include"

		# Read and embed function files
		$FunctionContent = @()
		$FunctionNames = @()

		foreach ($File in $FileList) {
			$FilePath = Join-Path -Path $SourcePath -ChildPath $File

			if (Test-Path -Path $FilePath) {
				Write-Verbose -Message "Reading function file: $FilePath"
				$Content = Get-Content -Path $FilePath -Raw

				# Extract function name from file
				if ($Content -match 'function\s+([\w-]+)') {
					$FunctionName = $Matches[1]
					$FunctionNames += $FunctionName
					Write-Verbose -Message "Found function: $FunctionName"
				}

				$FunctionContent += $Content
			}
			else {
				Write-Warning -Message "File not found: $FilePath"
			}
		}

		if ($FunctionNames.Count -eq 0) {
			throw "No functions found in the specified files."
		}

		# Generate changelog from Git history
		Write-Verbose -Message "Generating changelog from Git history"
		$GitHistory = git -C $SourcePath log --after="$GitStartDate" --pretty=format:"%h|%ad|%s" --date=short 2>$null

		if ($GitHistory) {
			$ChangelogContent = "Git History (After $GitStartDate):`n"
			foreach ($Commit in $GitHistory) {
				$Parts = $Commit -split '\|'
				if ($Parts.Count -ge 3) {
					$ChangelogContent += "- Commit $($Parts[0]) ($($Parts[1])): $($Parts[2])`n"
				}
			}
		}
		else {
			$ChangelogContent = "No Git history found after $GitStartDate."
		}

		# Try to read release notes if available
		$ReleaseNotesPath = Join-Path -Path $SourcePath -ChildPath "__ModuleBuildFiles"
		$ReleaseNotesFiles = Get-ChildItem -Path $ReleaseNotesPath -Filter "*$ModuleName*_ReleaseNotes*.txt" -ErrorAction SilentlyContinue

		if ($ReleaseNotesFiles) {
			$LatestReleaseNotes = $ReleaseNotesFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
			Write-Verbose -Message "Reading release notes from: $($LatestReleaseNotes.FullName)"
			$ReleaseNotesContent = Get-Content -Path $LatestReleaseNotes.FullName -Raw
			$ReleaseNotes = "$ReleaseNotesContent`n`n$ChangelogContent"
		}
		else {
			$ReleaseNotes = $ChangelogContent
		}

		# Extract module version if not specified
		if ([string]::IsNullOrWhiteSpace($ModuleVersion)) {
			if ($ReleaseNotesFiles) {
				$LatestReleaseNotes = $ReleaseNotesFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
				if ($LatestReleaseNotes.Name -match '(\d+\.\d+\.\d+\.\d+)') {
					$ModuleVersion = $Matches[1]
					Write-Verbose -Message "Extracted module version from release notes: $ModuleVersion"
				}
			}

			if ([string]::IsNullOrWhiteSpace($ModuleVersion)) {
				$ModuleVersion = "1.0.0.0"
				Write-Verbose -Message "Using default module version: $ModuleVersion"
			}
		}

		# Get author from git config if not specified
		if ([string]::IsNullOrWhiteSpace($Author)) {
			try {
				$GitAuthor = git -C $SourcePath config user.name 2>$null
				if ($GitAuthor) {
					$Author = $GitAuthor
					Write-Verbose -Message "Extracted author from git config: $Author"
				}
			}
			catch {
				# Ignore errors
			}

			if ([string]::IsNullOrWhiteSpace($Author)) {
				$Author = "Unknown"
			}
		}

		# Generate description if not specified
		if ([string]::IsNullOrWhiteSpace($Description)) {
			$Description = "PowerShell module for $ModuleName functions."
		}

		# Create PSM1 file with embedded functions
		$Psm1Path = Join-Path -Path $OutputPath -ChildPath "$ModuleName.psm1"
		Write-Verbose -Message "Creating PSM1 file: $Psm1Path"

		$Psm1Content = "# $ModuleName Module`n# Version: $ModuleVersion`n# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n"

		foreach ($Content in $FunctionContent) {
			$Psm1Content += $Content + "`n`n"
		}

		# Add export statement
		$Psm1Content += "# Export functions`nExport-ModuleMember -Function @(`n"
		foreach ($FuncName in $FunctionNames) {
			$Psm1Content += "    '$FuncName',`n"
		}
		$Psm1Content = $Psm1Content.TrimEnd(",`n") + "`n)"

		$Psm1Content | Out-File -FilePath $Psm1Path -Encoding UTF8 -Force
		Write-Verbose -Message "PSM1 file created successfully"

		# Create PSD1 file using New-ModuleManifest
		$Psd1Path = Join-Path -Path $OutputPath -ChildPath "$ModuleName.psd1"
		Write-Verbose -Message "Creating PSD1 file: $Psd1Path"

		$ManifestParams = @{
			Path              = $Psd1Path
			RootModule        = "$ModuleName.psm1"
			ModuleVersion     = $ModuleVersion
			Author            = $Author
			Copyright         = "(c) $(Get-Date -Format yyyy) $Author. All rights reserved."
			Description       = $Description
			PowerShellVersion = "5.1"
			FunctionsToExport = $FunctionNames
			CmdletsToExport   = @()
			VariablesToExport = @()
			AliasesToExport   = @()
			ReleaseNotes      = $ReleaseNotes
		}

		if (-not [string]::IsNullOrWhiteSpace($ProjectUri)) {
			$ManifestParams.ProjectUri = $ProjectUri
		}

		if (-not [string]::IsNullOrWhiteSpace($LicenseUri)) {
			$ManifestParams.LicenseUri = $LicenseUri
		}

		New-ModuleManifest @ManifestParams
		Write-Verbose -Message "PSD1 file created successfully"

		Write-Output "Module '$ModuleName' created successfully at: $OutputPath"
		Write-Output "Version: $ModuleVersion"
		Write-Output "Functions exported: $($FunctionNames.Count)"
		Write-Output "Functions: $($FunctionNames -join ', ')"
	}

	end {
		Write-Verbose -Message "New-mModuleFromFile - Module creation process completed"
	}
}
