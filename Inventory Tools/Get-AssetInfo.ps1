

$s = $Env:Computername
#Don't do a trailing slash or your socks will start to smell funny.

$WorkStationShare = "\\FileServer\Hardware\Workstations"
$MonitorShare = "\\FileServer\Hardware\Monitors"

$WShareName = "$WorkStationShare\$s.csv"
$MShareName = "$MonitorShare\$s.csv"

Try { [io.file]::OpenWrite($WShareName).close() }
Catch { 
    Write-Warning "Unable to write to output file $WshareName" 
    return 1;
}

Try { [io.file]::OpenWrite($MShareName).close() }
Catch { 
    Write-Warning "Unable to write to output file $MshareName" 
    return 1;
}

$MonitorArray = @();

$LastUser = Get-CimInstance Win32_UserProfile -Filter 'Special=FALSE' | Sort-Object LastUseTime -Descending |
Select-Object -First 1 | ForEach-Object {
    ([System.Security.Principal.SecurityIdentifier]$_.SID).Translate([System.Security.Principal.NTAccount]).Value
}

$CIMCS = Get-Ciminstance -class win32_ComputerSystem
$CPUInfo = $CIMcs.name
$MN = $CIMcs.Model

$OSInfo = Get-CIMinstance Win32_OperatingSystem
$OSInstallDate = $OSInfo.InstallDate

$CIMMemory = Get-CIMINStance CIM_PhysicalMemory
$OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
$OSTotalVisibleMemory = [math]::round(($OSInfo.TotalVisibleMemorySize / 1MB), 2)
$PhysicalMemory = [Math]::Round((($CIMMemory | Measure-Object -Property capacity -sum).sum / 1GB), 2)

$CIMBios = Get-Ciminstance Win32_BIOS
$SN = $CIMBios.serialnumber
$MF = $CIMBios.manufacturer

$CIMDisk = Get-Ciminstance Win32_logicalDisk
$DISKTOTAL = $CIMDisk | Where-Object caption -eq "C:" | foreach-object { Write-Output "$('{0:N2}' -f ($_.Size/1gb)) GB " }
$DISKFREE = $CIMDisk | Where-Object caption -eq "C:" | foreach-object { Write-Output "$('{0:N2}' -f ($_.FreeSpace/1gb)) GB " }
    
$CIMNetwork = Get-CimInstance Win32_NetworkAdapter
$WifiMac = $CIMNetwork | Where-Object { $_.Name -match ("Wireless|wifi|wi\-fi") -and ($_.name -notlike "*virtual*") } | 
Select-object -ExpandProperty MacAddress
    
$CIMNetCfg = Get-Ciminstance Win32_NetworkAdapterConfiguration    
$MAC = $CIMNetCfg | Where-Object { $_.ipenabled -EQ $true } | select-object -first 1 -ExpandProperty MacAddress

$CIMMonitors = Get-WMIObject WmiMonitorID -Namespace root\wmi

$CIMChassis = Get-CimInstance Win32_SystemEnclosure | Select-object -ExpandProperty ChassisTypes

$BuiltInChassis = @("8","9","10","11","13","14")
if (($CIMChassis -in $BuiltInChassis) -and ($CIMMonitors.count -le 1)) {$BuiltInOnly = $true }

## Really hacky check to ensure I don't pull in thousands of built-in displays from laptops. 

if (-not($BuiltInOnly)) {
    ForEach ($Monitor in $CIMMonitors) {
        $monitorData = @();
        $Manufacturer = ($Monitor.ManufacturerName -ne 0 | ForEach-Object { [char]$_ }) -join ""
        if ($monitor.UserFriendlyName) { 
            $Name = ($Monitor.UserFriendlyName -ne 0 | ForEach-Object { [char]$_ }) -join "" 
        }
        else {
            $Name = ($Monitor.ProductCodeID -ne 0 | ForEach-Object { [char]$_ }) -join ""
        }

        #Do some voodoo to clean up Lenovo Monitor names and take out the Manufacturer code
        if ($Name -like "LEN *") {
            $Name = $name.split(' ')[1]
        }


        #If you need to beef up this list, start here: https://github.com/MaxAnderson95/Get-Monitor-Information/blob/master/Get-Monitor.ps1
        #If you need more beef:  go here : http://edid.tv/manufacturer/

        $Serial = ($Monitor.SerialNumberID -ne 0 | ForEach-Object { [char]$_ }) -join ""
        
        switch ($Manufacturer) {
            'LEN' { $Make = "Lenovo" }
            'ACI' { $Make = "ASUS" }
            'LGD' { $Make = "LG" }
            'SDC' { $Make = "Surface Display" }
            'SEC' { $Make = "Epson" }
            'SAM' { $Make = "Samsung" }
            'SNY' { $Make = "Sony" }
            'GSM' { $Make = "LG (Goldstar) TV" }
            'GWY' { $Make = "Gateway 2000" }
            'ITE' { $Make = "Integrated Tech Express" }
            
            default { $Make = "Unknown: $Manufacturer" }
        }
     
        $Friendly = "[$make] ${name}: $serial"   

        $MonitorData = [PSCustomObject] @{
            Vendor        = $Make
            Model         = $Name
            Serial        = $Serial
            Friendly      = $Friendly
            'Last Seen'   = $(Get-Date)
            'Attached To' = $s
        } 
        $MonitorArray += $MonitorData
    }
}


switch ($CIMChassis) {
    ## https://www.dmtf.org/sites/default/files/standards/documents/DSP0134_3.1.1.pdf
    ## Chassis types liberated from this PDF
    
    "1"	{ $Chassis = "Other" }
    "2"	{ $Chassis = "Unknown" }
    "3"	{ $Chassis = "Desktop" }
    "4"	{ $Chassis = "Low Profile Desktop" }
    "5"	{ $Chassis = "Pizza Box" }
    "6"	{ $Chassis = "Mini Tower" }
    "7"	{ $Chassis = "Tower" }
    "8"	{ $Chassis = "Portable" }
    "9"	{ $Chassis = "Laptop" }
    "10"	{ $Chassis = "Notebook" }
    "11"	{ $Chassis = "Hand Held" }
    "12"	{ $Chassis = "Docking Station" }
    "13"	{ $Chassis = "All in One" }
    "14"	{ $Chassis = "Sub Notebook" }
    "15"	{ $Chassis = "Space-saving" }
    "16"	{ $Chassis = "Lunch Box" }
    "17"	{ $Chassis = "Main Server Chassis" }
    "18"	{ $Chassis = "Expansion Chassis" }
    "19"	{ $Chassis = "SubChassis" }
    "20"	{ $Chassis = "Bus Expansion Chassis" }
    "21"	{ $Chassis = "Peripheral Chassis" }
    "22"	{ $Chassis = "RAID Chassis" }
    "23"	{ $Chassis = "Rack Mount Chassis" }
    "24"	{ $Chassis = "Sealed-case PC" }
    "25"	{ $Chassis = "Multi-system chassis" }
    "26"	{ $Chassis = "Compact PCI" }
    "27"	{ $Chassis = "Advanced TCA" }
    "28"	{ $Chassis = "Blade" }
    "29"	{ $Chassis = "Blade Enclosure" }
    "30"	{ $Chassis = "Tablet" }
    "31"	{ $Chassis = "Convertible" }
    "32"	{ $Chassis = "Detachable" }
    "33"	{ $Chassis = "ioT Gateway" }
    "34"	{ $Chassis = "Embedded PC" }
    "35"	{ $Chassis = "Mini PC" }
    "36"	{ $Chassis = "Stick PC" }
    default { $Chassis = "Invalid Chassis Type" }
}


$MonitorFriendly = $MonitorArray.Friendly -join ', '

$AT = $s
$status = "Ready to Deploy"

$IP = (Test-Connection $CPUInfo -count 1).IPv4Address.IPAddressToString

Foreach ($CPU in $CPUInfo) {
    $infoObject = [PSCustomObject][ordered]@{
        #The following add data to the infoObjects.	
        "Asset: Name"                   = $CPUInfo
        "Asset: Tag"                    = $AT
        "Asset: Model Number"           = $MN
        "Asset: Manufacturer"           = $MF
        "Asset: Serial Number"          = $SN

        "Inventory: Status"             = $status
        "Inventory: Timestamp"          = $(Get-Date)
        "Inventory: Chassis"            = $Chassis

        "OS: Name"                      = $OSInfo.Caption
        "OS: Install Date"              = $OSInstallDate
        "OS: Last User"                 = $lastuser

        "Sub-Assets: Monitors"          = $MonitorFriendly

        "Specs: Physical RAM"           = $PhysicalMemory
        "Specs: Virtual Memory"         = $OSTotalVirtualMemory
        "Specs: Visable Memory"         = $OSTotalVisibleMemory
        "Specs: Total Disk Space"       = $DISKTOTAL
        "Specs: Free Disk Space"        = $DISKFREE

        "Network: IP Address"           = $IP
        "Network: Wireless MAC Address" = $WifiMAC
        "Network: Ethernet MAC Address" = $MAC
    }


}

$infoObject | Export-Csv -Path $WshareName -NoClobber -NoTypeInformation -Encoding UTF8 -Append -Force
$MonitorArray | Select-Object Vendor, Model, Serial, 'Last Seen', 'Attached To' | Export-Csv -Path $MShareName -NoTypeInformation -Encoding UTF8 -Force
