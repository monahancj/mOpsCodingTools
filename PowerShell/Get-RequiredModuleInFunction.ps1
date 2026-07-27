function Get-RequiredModuleInFunction {
	
<#
    .SYNOPSIS
        A brief description of the function or script. This keyword can be used
        only once in each topic.

    .DESCRIPTION
        A detailed description of the function or script. This keyword can be
        used only once in each topic.

    .PARAMETER  <Parameter-Name>
        The description of a parameter. Add a .PARAMETER keyword for
        each parameter in the function or script syntax.

    .EXAMPLE
        A sample command that uses the function or script, optionally followed
        by sample output and a description. Repeat this keyword for each example.

    .INPUTS
        The Microsoft .NET Framework types of objects that can be piped to the
        function or script. You can also include a description of the input
        objects.

    .OUTPUTS
        The .NET Framework type of the objects that the cmdlet returns. You can
        also include a description of the returned objects.

    .NOTES
        Additional information about the function or script.

		Original Author: YOUR NAME HERE, companyname GTIS
		Contributors:	 name,org
	
	.LINK
		https:\\linktogithublocation
	
#>
	#TODO: Fill out the comment based help.
	
	[cmdletbinding(SupportsShouldProcess = $True)]#TODO: Evaluate if SupportsShouldProcess is appropriate for the script.
	param (
		[Parameter(Position = 0, Mandatory = $true,  ValueFromPipeline = $true) ]$Param1,
		[Parameter(Position = 1, Mandatory = $false, ValueFromPipeline = $true) ]$Param2,
		[Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $false)]$Param3
	)
	
	begin {
		# Code to be executed once BEFORE the pipeline is processed goes here.
		
		if (Test-Path -Path function:\Get-mCurrentLine) { Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function $($_) is loaded in the session." }
		else { throw "$(Get-Date)- $($MyInvocation.InvocationName) - Line 44 or so - Function $($_) is not loaded in the session." }
		
		Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function started."
		
		# Test for required modules
		$ModuleList = "InsertAModuleNameHere", "InsertAnotherModuleNameHere"
		$ModuleList | ForEach-Object {
			if (Test-mIsModuleLoaded -Name $_) { Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is loaded in the session." }
			else { throw "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Module $($_) is not loaded in the session." }
		}
		
		# Test for required functions that aren't in required modules
		$FunctionList = "InsertAFunctionNameHere", "InsertAnotherFunctionNameHere"
		$FunctionList | ForEach-Object {
			if (Test-Path -Path function:\"$($_)") { Write-Verbose -Message "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function $($_) is loaded in the session." }
			else { throw "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function $($_) is not loaded in the session." }
		}
		
	} # end begin block
	
	process {
		# Code to be executed against every object in the pipeline goes here.
		Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Process block start - param1 $($param1) - param2 $($param2) - param3 $($param3)"
		
		#TODO: Validate the parameters as needed.
		
		#TODO: Overview- Loop through module(s) to list commands and use Select-String -Quiet to find a command in the function.  If there's a hit then the module is required.
		#TODO: Parameter 1- Function to search.  Parameter 2- Module(s) to check
		
	} #end of the process block
	
	end {
		# Code to be executed once AFTER the pipeline is processed goes here.
		
		# While testing, in the line below comment out "-ErrorAction SilentlyContinue"
		Remove-Variable Param1, Param2, Param3 #-ErrorAction SilentlyContinue -WhatIf:$false # Using -WhatIf:$false to suppress unnecessary messages when a calling function has -Whatif:$true enabled.
		
		[System.GC]::Collect() # Memory cleanup
		
		Write-Verbose "$(Get-Date)- $($MyInvocation.InvocationName) - Line $(Get-mCurrentLine) - Function ended."
		
	} #end of the end block
	
} # end of the function
