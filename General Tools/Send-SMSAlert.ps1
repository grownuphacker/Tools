<#

.NOTES
Author:      Adam "Abe" Abernethy
Twitter:     @ReallyBigAbe
Go here:     https://blueteam.ninja
  
Don't be a mean person. 

.SYNOPSIS

Send an SMS over Plivo

.DESCRIPTION

This makes a simple API call using the Plivo API, passing on your number and Credentials

.PARAMETER recipients

All destination numbers in a string.  Numbers include country code, and are separated by 
the less-than symbol.  <

.PARAMETER source

Your source phone number based on your account. 

.PARAMETER message

The Content of your SMS.

.PARAMETER plivoID

The 20 character ID of your Plivo account

.PARAMETER AuthKey

Your authentication to the API.  I believe these are typically 40 characters



.INPUTS

None. Not pipeable at this time. 

.OUTPUTS

The JSON results returned by the API. 

.EXAMPLE

C:\PS> Send-SMSALert -recipients 12023034444<13134145555 -source 15550009999 `
    -plivoID ABCDEFGHIJKLMNOPQRST -AuthKey AABBCCDDEEFFGGHHIIJJKKLLMMNNOOPPQQRRSSTT `
    -message "You may turn in your hat and badge, thank-you for your service"

.EXAMPLE

C:\PS> $smsparms = @{
    'recipients' = '12023034444<13134145555';
    'source' = '15550009999';
    'plivoID' = 'ABCDEFGHIJKLMNOPQRST';
    'AuthKey' = 'AABBCCDDEEFFGGHHIIJJKKLLMMNNOOPPQQRRSSTT'
    'message' = "You may turn in your hat and badge, thank-you for your service"
}
C:\PS>Send-SMSAlert $smsparms

 

#>

param (
    [Parameter(Mandatory=$true)]
        [string]$recipients,
    [Parameter(Mandatory=$true)]
        [string]$source,
    [Parameter(Mandatory=$true)]
        [string]$message,
    [Parameter(Mandatory=$true)]
        [string]$plivoID,
    [Parameter(Mandatory=$true)]
        [string]$AuthKey
)

$plivoAUTH = ConvertTo-SecureString -String $AuthKey -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $plivoID, $plivoAUTH
$baseURI = "https://api.plivo.com/v1/Account/" + $plivoID + "/Message/"

$params = @"
{
"src": "$source",
"dst": "$recipients",
"text": "$message"
}
"@

Invoke-WebRequest -Credential $credential -Uri $baseURI -Method POST -ContentType application/json -body $params

