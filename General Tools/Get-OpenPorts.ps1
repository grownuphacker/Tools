<#

.NOTES
Author:      Adam "Abe" Abernethy
Twitter:     @ReallyBigAbe
Go here:     https://blueteam.ninja
  
Don't be a mean person. 

.SYNOPSIS

Displays the listening ports and what's listening.

.DESCRIPTION

A cmdlet that I use quite regularly as a replacement for netstat.  It's bound, so you run it once or drop it in a profile and 
just keep profitting.  Depending on how much SVCHost you have, it can be a bit sluggish - but that's because WMI queries tend to suck. 

More importantly, I suck at writing them fast.

.PARAMETER Nada

Nothing to see here.  Move along. 


.INPUTS

None. Not pipeable at this time. 

.OUTPUTS

The output from the Get-NetTCPConnection formatted as per my will, grouped by IP Type, then Port.   

.EXAMPLE

C:\PS>.\Get-OpenPorts.ps1
C:\PS> Get-OpenPorts

[List displayed]

#>

Function Get-OpenPorts {            
[cmdletbinding()]            
param()      
 $results = @()           
    
    $GlobalListeners = Get-NetTCPConnection | Where-Object {$_.State -eq "Listen"}
    
    foreach($Listening in $GlobalListeners) {
        #Reset the variable
        $ListenerProcess = $null            
        try{
        $ListenerProcess = (Get-Process -PID $Listening.OwningProcess).ProcessName
        }catch{}
            if($ListenerProcess -eq "svchost"){
                try{
                    $ListenerProcess += ": " + (Get-WmiObject -Class Win32_Service | Where-Object {$_.ProcessID -eq $Listening.OwningProcess}).Name
                } catch{}
            }
            
        if($Listening.LocalAddress -match ":"){
            $IPType = "IPv6"
            }else{
                $IPType = "IPv4"
            }
        $lineout = New-Object PSobject -Property @{             
        "Local Address" = $Listening.LocalAddress;            
        "Listening Port" = $Listening.LocalPort;            
        "IP Type" = $IPType
        "Process Name" = $ListenerProcess
        "PID" = $Listening.OwningProcess
        }

        $results += $lineout
    }            
        
$results | Sort-Object -Property "IP Type","Listening Port"
}
