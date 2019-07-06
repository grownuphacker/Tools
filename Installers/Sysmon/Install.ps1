$Source = "\\FileServer\Location\Sysmon.exe"
$configSource = "\\FileServer\Location\SwiftOnSecurity.XML"

# Temp the TMP like a boss
$rollback = $env:TMP
$env:TMP = $SystemDrive\Temp\
try{
new-item -type Directory "$Env:TMP" -errorAction Stop
}catch{return 666}

if(!(Test-Path $source)){return 667}

Copy-Item $source $env:TMP
Start-Process -FilePath $env:TMP\sysmon.exe -ArgumentList "-acceptEula -i $configSource" -wait

# Cleanup and go home, folks. 
Remove-Item "$env:TMP" -recurse -force -errorAction silentlyContinue
$env:tmp = $rollBack

## Lemme know if there any typos, mmkay?
## Abe - Chief Ninja - https://blueteam.ninja
