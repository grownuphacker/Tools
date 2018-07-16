
#Step 1:  Determine if Exchange is actually blown up

try{
$status = get-service MSExchangeTransport -ErrorAction Stop
}catch {
    Write-Output "Error: Exchange Transport Service Not found"
    exit 1;
}
    if($status.Status -eq "Running") {
        Write-Output "Error: Exchange Transport Service is not Down.  This script won't help you."
        exit 1;
    }

#Step 2:  Parse the Config and load up some variables
try{
$config = get-content "$env:ExchangeInstallPath\bin\EdgeTransport.exe.config" -ErrorAction Stop
$configtable = $config | 
Where-Object {
    $_ -match "key=" -and $_ -match "value="
} | 
    ForEach-Object{
        @{[regex]::Matches($_,'key="(.*?)"').Groups[1].Value = [regex]::Matches($_,'value="(.*?)"').Groups[1].Value}
    }

$DBPath = $configtable.QueueDatabasePath
$DBLoggingPath = $configtable.QueueDatabaseLoggingPath
}catch {
    Write-Output "Error: Unable to parse Exchange Transport Configuration correctly"
    exit 1;
}

#Step 3:  Ensure the Paths are legit
try{
    Test-Path $DBPath
    Test-Path $DBLoggingPath
} catch {
    Write-Output "Error: Unable to access or locate Queue Paths"
    exit 1;
}

#Step 4:  Rename / Backup existing DB Folders.
#Note:  This is the part where you might break something
#Use with Caution, do not fold or bend, click I agree etc.

try {
    Rename-Item -path $DBPath -newName ("DB" + "." + (Get-Date -Format MMddyyyy)) -Force -ErrorAction Stop
    Rename-Item -path $DBLoggingPath -newName ("DBLog" + "." + (Get-Date -Format MMddyyyy)) -Force -ErrorAction Stop
}catch {
    Write-Output "Error: Unable to Rename Queue DB or Queue DB Logs"
    exit 1;
}

#Step 5:  Start the service back up
try { 
    Start-Service $status -ErrorAction Stop
} catch{
    Write-output "Error: Remediation Attempted, Service still won't start. "
    exit 1;
}

Write-Output "Script executed Successfully"
exit 0;