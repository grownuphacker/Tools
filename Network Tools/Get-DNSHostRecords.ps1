# By Abe - https://blueteam.ninja


# Get your current DNS to find the server
$myDns = Get-DnsClientServerAddress | Select-Object -ExpandProperty ServerAddresses -First 1 | select-object -First 1

# Grab the zones
$zones = Get-DnsServerZone -ComputerName $MyDns | Where-Object {($_.ZoneName -notlike "*.in-addr.arpa") -and ($_.zoneName -notlike "_msdcs*")} | 
    Select-object -ExpandProperty ZoneName

$results = @();

foreach($zone in $zones){

$records = Get-DnsServerResourceRecord -ZoneName $Zone -ComputerName $myDns | where-Object {($_.RecordType -like "A") -or ($_.RecordType -like "CNAME") -or ($_.RecordType -like "AAAA")} | 
    Where-Object {$_.HostName -notlike "*${Zone}"} 
    


foreach($record in $records) {
$lineout = @();        
    
        if($record.RecordData.IPV4Address.IpAddressToString){
            $recordType = "IP4"
            $recordData = $record.RecordData.IPV4Address.IpAddressToString
        }elseif($record.RecordData.IPV6Address.IpAddressToString){
            $recordType = "IP6"
            $recordData = $record.RecordData.IPV6Address.IpAddressToString
        }else{
            $recordType = "Data"
            $recordData = $record.RecordData.HostNameAlias
        }
        
        $hostData = $record.HostName
        if($HostData -eq "@") {
            $URI = "${zone}"
        }else{
            $Uri = "${HostData}.${zone}"
        }

        $lineout = [PSCustomObject] @{
            "Host" = $hostData
            "URI" = $Uri    
            "Record Type" = $recordType
            "Record Data" = $recordData
            "Domain" = $Zone
            
        }

        $results += $lineout
}

}

$results
