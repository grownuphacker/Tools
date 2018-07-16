Function Get-ViewAgentLog
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]
        $filePath
    )

$filepath = "C:\Utilities\scripts\debug-2018-06-19-140439.txt"
$results = @();
$header = @"
<?xml version=`"1.0`"?>
<LOGS>
"@
$log = Get-Content $filePath | Select-String -SimpleMatch "<TERMINALRESPONSE>"
$footer = @"
</LOGS>
"@

try{
$sessiondata = ([xml]($header + $log + $footer)).LOGS.TERMINALRESPONSE.SESSION
} catch{
    return;
}
$sessiondata = $sessiondata | Where-Object {$_.SESSIONGUID -ne $null} | SELECT SESSIONGUID,STARTTIME,STARTTICK,FIRSTCONNECTTICK,LASTCONNECTTICK,LASTDISCONNECTTICK,LOGOFFTICK

foreach($session in $sessiondata) { 
    $timestamp = (Get-Date "1970-01-01 00:00:00.000Z") + ([TimeSpan]::FromSeconds($($session.STARTTIME)))
    $lineout = New-Object -Type psobject -Property @{
        SessionID = $session.SESSIONGUID
        User = $session.USERNAME
        Domain = $session.DOMAINNAME
        HomePC = $session.CLIENTNAME
        Protocol = $session.Protocol
        State = $session.State
        TimeStamp = $timestamp
        ViewServer = $session.SECURITYGATEWAYID
        Log = $filePath        
    }
$results += $lineout
}

return $results
}

$files = Get-ChildItem -Path "C:\Utilities\scripts" -Filter debug*.txt -File
$exportPath = "C:\Utilities\scripts\ViewLog.csv"

$history = $files.FullName | Foreach{ 
    Write-Progress -Activity "Scanning Debug Logs" -Status "Parsing $_"
    Get-ViewAgentLog -filePath $_ 
    }

$history | Export-Csv -Path $exportPath -NoClobber -NoTypeInformation -Force
$history