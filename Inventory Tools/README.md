# SCCM / Snipe IT Inventory Automation

### Dependencies
> `Install-Module SnipeITPS`
> Snipe API Key with permissions to view and create...pretty much everything. 
> Every MODEL NUMBER needs to be in Snipe IT (*WILL* Fail without)
> Every Location needs to be in Snipe IT (Won't Fail without)
> Those locations need their DHCP address scopes in the proper Function in Set-AssetInfo
> User Affinity enabled in SCCM.  

## What does it do?

The `Get-AssetInfo.ps1` is meant to be run at Startup or as an SCCM SCript (It works running as SYSTEM).  It will gather the relevant information
and much more and send it to a file share.  This is what it gathers: 
```
Asset: Name                   : PC-HOSTNAME      
Asset: Tag                    : PC-HOSTNAME      
Asset: Model Number           : XXYYZZ     
Asset: Manufacturer           : LENOVO
Asset: Serial Number          : AAABBBCCDD       
Inventory: Status             : Ready to Deploy
Inventory: Timestamp          : 10/04/2019 10:15:54 AM
Inventory: Chassis            : Desktop
OS: Name                      : Microsoft Windows 10 Enterprise
OS: Install Date              : 08/03/2019 5:31:17 PM
OS: Last User                 : DOMAIN\username
Sub-Assets: Monitors          : [Lenovo] ModelXXYY: SERIAL, [Lenovo] ModelXXYY: SERIAL
Specs: Physical RAM           : 16
Specs: Virtual Memory         : 18.27
Specs: Visable Memory         : 15.9
Specs: Total Disk Space       : 235.48 GB
Specs: Free Disk Space        : 110.32 GB 
Network: IP Address           : 10.10.10.5
Network: Wireless MAC Address :
Network: Ethernet MAC Address : AA:BB:CC:11:22:33
```

It also parses out to the best of my ability monitor information - and matches them against a spreadsheet with Serial numbers that match Model numbers: 
```
Vendor      : Lenovo
Model       : ModelXXYY
Serial      : SERIALA
Friendly    : [Lenovo] ModelXXYY: SERIALA
Last Seen   : 10/04/2019 10:15:54 AM
Attached To : PC-HOSTNAME

Vendor      : Lenovo
Model       : ModelXXYY
Serial      : SERIALB
Friendly    : [Lenovo] ModelXXYY: SERIALB
Last Seen   : 10/04/2019 10:15:54 AM
Attached To : PC-HOSTNAME
```

Using these CSVs - I used https://github.com/snazy2000/SnipeitPS @Snazzy2000 's Powershell API wrapper (One day I'll probably fork it out, but its pretty awesome as is!)
then I dump in all the information - with most of the extra information in notes.  So you can easily find the last time a PC was inventoried. 

Set it up as a scheduled task at login - and also add it as a Script in SCCM and you're good to go.
