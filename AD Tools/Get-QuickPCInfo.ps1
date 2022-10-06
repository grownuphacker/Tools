# Just testing a PR

$source = get-content "C:\Utilities\data\updates.txt"
$results = @();

foreach ($PC in $Source) {
    try{
    $test = Test-Connection $PC -Count 1 -ErrorAction Stop
    if($test){$connection = "Success"}
    }catch{
    $connection = "Connection Failed"
    }

    try{
        $User = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $PC -ErrorAction Stop).UserName
            if($User -eq ""){$user = "None"}
    }catch{
        $User = "#WMI Failure"
    }

    try{
        $Computer = Get-ADcomputer -Identity $PC -Properties IPV4Address,OperatingSystem,PasswordLastSet | Select-Object Name,IPV4Address,OPeratingSystem,PasswordLastSet,DistinguishedName -ErrorAction Stop
    }catch{
        $connection = "AD Lookup Failed"
    }

    $ou = ($Computer.distinguishedName -split ",OU=",0,"RegexMatch")[1]
    $lineout = New-Object PSObject -Property @{
        Host = $PC
        'IP Address' = $Computer.IPV4Address
        'Operating System' = $Computer.OperatingSystem
        'Last Activity' = $Computer.PasswordLastSet
        'Current User' = $User
        'AD OU' = $ou
    }

    $results += $lineout


}

$results
