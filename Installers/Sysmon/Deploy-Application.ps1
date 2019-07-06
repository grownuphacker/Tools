<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
	# LICENSE #
	PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows. 
	Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
.EXAMPLE
    Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK 
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	
	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'Sysinternals'
	[string]$appName = 'Sysmon'
	[string]$appVersion = '10.1'
	[string]$appArch = 'x64'
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '02/12/2017'
	[string]$appScriptAuthor = 'Big Abe'
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = ''
	[string]$installTitle = ''
	
	##* Do not modify section below
	#region DoNotModify
	
	## Variables: Exit Code
	[int32]$mainExitCode = 0
	
	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.7.0'
	[string]$deployAppScriptDate = '02/13/2018'
	[hashtable]$deployAppScriptParameters = $psBoundParameters
	
	## Variables: Environment
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
	
	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}
	
	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================
		
	If ($deploymentType -ine 'Uninstall') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

		## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
		#Show-InstallationWelcome -CloseApps 'iexplore' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
		
		## <Perform Pre-Installation tasks here>

		#stop any Processes - save some headache
		get-service sysmon -ErrorAction SilentlyContinue | stop-service -ErrorAction SilentlyContinue
		get-service sysmon64 -ErrorAction SilentlyContinue | stop-service  -ErrorAction SilentlyContinue

		## Use these binaries to uninstall any troubleshooting / snowflake entries ( I found a LOT in my shop)
		
		Execute-Process -Path "sysmon.exe" -Parameters "-u force" -WindowStyle 'Hidden' -ContinueOnError:$true
		Execute-Process -Path "sysmon64.exe" -Parameters "-u force" -WindowStyle 'Hidden' -ContinueOnError:$true
		
		## Go big on the failed deployment checking
		## Using PSADT to run 'sc delete' kind of feels like using a corvette to pull a wagon
		# I used start-process originally - but forgot to add the -wait so I broke lots of things and blamed everyone but myself.
		Execute-Process -Path "sc.exe" -Parameters "delete sysmon" -WindowStyle 'Hidden' -ContinueOnError:$true
		Execute-Process -Path "sc.exe" -Parameters "delete sysmon64" -WindowStyle 'Hidden' -ContinueOnError:$true

		
		## Remove any existing orphaned binaries
		Remove-File -Path "$env:windir\sysmon64.exe" -erroraction SilentlyContinue
		Remove-File -Path "$env:windir\sysmon.exe" -erroraction SilentlyContinue
		Remove-File -path "C:\windows\CCMTEMP\sysmon.exe" -erroraction SilentlyContinue

		## Create the workaround folder. 
		New-Item "C:\Temp" -itemType Directory -Force


		##*===============================================
		##* INSTALLATION 
		##*===============================================
		[string]$installPhase = 'Installation'
		
		## Handle Zero-Config MSI Installations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) { $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } }
		}
		
		## <Perform Installation tasks here>
		#Workaround because Sysmon hates me!
		#    (Much frustration later comment) Turns out Sysmon hates others:  `
		#    https://social.technet.microsoft.com/Forums/azure/en-US/a89efd1d-878d-4b75-ae8e-6daefbcec6cc/sysmon-5200-deployment-issues-via-sccm?forum=miscutils
		# Copy to a temp
		
		Copy-Item "$dirFiles\sysmon.exe" "C:\Temp\" -Force
		Copy-Item "$dirSupportFiles\sysmonconfig-export.xml" "C:\Temp\" -Force
		
		# More Workaround because CCM Client hates me.  This is getting ridiculous.
		# Read more... where some internet stranger called me 'Ape'
		# https://social.technet.microsoft.com/Forums/en-US/a89efd1d-878d-4b75-ae8e-6daefbcec6cc/sysmon-5200-deployment-issues-via-sccm?forum=miscutils

		$env:TMP = "C:\Temp\"

		# Basic install with whatever config is in this folder
		Start-Process -FilePath "C:\Temp\sysmon.exe" -ArgumentList "-accepteula -i `"C:\Temp\sysmonconfig-export.xml`" -n" -WindowStyle Hidden -Wait
		
		# Add the permissions for Windows Event Forwarding. 
		# Don't be a muppet, move gradually from WEF to SIEM - or just thank me for setting the permissions.  		
		Start-Process -Filepath 'wevtutil.exe' `
			-ArgumentList "sl Microsoft-Windows-Sysmon/Operational /ca:O:BAG:SYD:(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x1;;;BO)(A;;0x1;;;SO)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;S-1-5-20)" `
			-Wait

		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'
		
		## <Perform Post-Installation tasks here>
		
		# Track versions in teh registry to make detection and version changes easy.
		# Just blow me kisses across a conference floor next time you upgrade sysmon . . .
		
		New-Item HKLM:\Software\Sysmon
			Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Sysmon' -name 'version' -value $appVersion
		
		# Sweep the floor behind ourselves on the way out the door. 
		Remove-Item C:\Temp -Recurse -Force -confirm:$false
		$env:TMP = "C:\Windows\CCMTemp\"
		## Display a message at the end of the install
		If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'SYSMON has been installed and configured' -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'
		
		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
		## <Perform Pre-Uninstallation tasks here>
		
		
		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'
		
		## Handle Zero-Config MSI Uninstallations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}
		
		# <Perform Uninstallation tasks here>
		
		if(Test-Path $env:windir\sysmon.exe -PathType 'Leaf') {
        	Execute-Process -Path "$env:windir\Sysmon.exe" -Parameters '-u' -WindowStyle 'Hidden'
			Remove-File -Path "$env:windir\sysmon.exe"
		}

		## Use our custom version numbers to track the config and the installed versions.
		
		
		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'
		
		## Registry Cleanup

		## <Perform Post-Uninstallation tasks here>
		try{
			$sysmonflag = Get-ItemProperty HKLM:\Software\Sysmon\ -erroraction stop | Select-Object -expandproperty version
		}catch{}
	
		if($sysmonflag){Remove-ItemProperty HKLM:\Software\Sysmon -name version}
		remove-item "HKLM:\Software\Sysmon"
	}
	
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================
	
	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}
