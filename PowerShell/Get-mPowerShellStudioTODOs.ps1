Function Get-mPowerShellStudioTODOs {
#TODO: Rename to "Get-TODOsFromCode".  I'm using the "TODO:" convention generally now, and it's not necessarily PowerShell specific.
#TODO: Add a parameter "-PowerShell" to search for the string "#TODO:"
#TODO: Add a parameter "-TODOstring" to search on a custom string
#TODO: Update to use current standard template

<#
    .SYNOPSIS
		A brief description of the function or script. This keyword can be used only once in each topic.

	.DESCRIPTION
        A detailed description of the function or script. This keyword can be used only once in each topic.

	.PARAMETER  <Parameter-Name>
        The description of a parameter. Add a .PARAMETER keyword for each parameter in the function or script syntax.

	.INPUTS
        The Microsoft .NET Framework types of objects that can be piped to the function or script. You can also include a description of the input objects.

	.OUTPUTS
        The .NET Framework type of the objects that the cmdlet returns. You can also include a description of the returned objects.

	.NOTES
        Additional information about the function or script.

		Original Author: YOUR NAME HERE, companyname GTIS
		Contributors:	 name,org

	.EXAMPLE
        A sample command that uses the function or script, optionally followed by sample output and a description. Repeat this keyword for each example.

	.LINK
		https://github.monster.com/OPS/mVMwarePowerCLI/blob/master/vm/Verb-Noun.ps1
#>

	[cmdletbinding(SupportsShouldProcess = $false)]
	param (
		[Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]$File
	)

	begin {	# code to be executed once BEFORE the pipeline is processed goes here
        
		# code to be executed once BEFORE the pipeline is processed goes here

		Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function started"
		Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Begin block start"

		$RequiredModules = "mWindowsGeneral"
		$RequiredModules | ForEach-Object {
			if (Test-mIsModuleLoaded -Name $_) {
				Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Test if module loaded passed: $($_)" }
			else {
				throw "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Test if module loaded failed: $($_) ABORTING" }
		}

		$RequiredFunctions = "Get-mCurrentLine"
		$RequiredFunctions | ForEach-Object {
			if (Test-Path -Path function:\\$_) {
				Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Test if function loaded passed: $($_)" }
			else {
				throw "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Test if function loaded failed: $($_) ABORTING" }
		}

		# Static Variables
		# None

		Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Begin block End"

	} # end begin block

	process { # code to be executed against every object in the pipeline goes here

		# If -Verbose present then list the passed parameters and their values.  This is done in the process block instead of the begin block because if the function is used in a pipeline only the first set of variables would be listed.
		if ($VerbosePreference -ne 'SilentlyContinue') {
			# Get the command name
			$CommandName = $PSCmdlet.MyInvocation.InvocationName;
			# Get the list of parameters for the command
			$ParameterList = (Get-Command -Name $CommandName).Parameters;

			# Grab each parameter value, using Get-Variable
			foreach ($Parameter in $ParameterList) {
				Get-Variable -Name $Parameter.Values.Name -ErrorAction SilentlyContinue;
				#Get-Variable -Name $ParameterList;
			}
		}

		# Validate inputs
		if (Test-Path -Path $File)
		{
			$File = Get-ChildItem $File
            Get-Content $File | Select-String -Pattern "todo" | Select-Object @{ n = 'Directory'; e = { $File.Directory } },@{ n = 'File'; e = { $File.Name } }, LineNumber, @{ n = 'Text'; e = { $_.Line.Trim() } }
        }
        else { Write-Error "$(Get-Date) - $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - File not found, skipping: $($File)" }

	} #end of the process block

	end { # code to be executed once AFTER the pipeline is processed goes here

		Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - End block start"
		
		Remove-Variable RequiredModules, RequiredFunctions, Param1, Param2, Param3 -ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		[System.GC]::Collect() # Memory cleanup

		Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - End block end"
		Write-Verbose "$(Get-Date) - $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function Finished"

	} #end of the end block

} # end function
