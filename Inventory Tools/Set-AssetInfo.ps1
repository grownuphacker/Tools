$Wshare = "\\FileServer\hardware\Workstations"
$Mshare = "\\FileServer\hardware\Monitors"
$TagFile = "\\FileServer\MonitorTags.csv"

$SnipeURL = "https://inventory.domain.com"

try{
    $SnipeAPI = Get-content "$PSScriptRoot\key.txt"
    Set-Info -url $SnipeURL -apiKey $SnipeAPI -ErrorAction Stop
}catch{
    #I use this for SCCM Exit codes
    #I also lean on POSIX error codes because I'm a greybeard and wokefulness is lit, fam.
    return 126;
    
}

Function Get-LocationNameFromIP {
    [CmdletBinding()]

    Param(
        [string]$ip
    )
    switch -Wildcard ($ip){
        '10.100.0.*' {$location="Main Building - Basement"}
        '10.100.1.*' {$location="Main Building - Floor 1"}
        '192.168.*.*' {$location="Guest Wifi"}
        '10.110.0.*' {$location="Legacy LAN"}
        default {$location ="Unknown"}

    }
return $location


}


$WItems = @();

Get-ChildITem "$Wshare\*.csv"  | ForEach-Object{
    $WItems += Import-Csv $_ | Sort-Object 'Inventory: Timestamp' -Descending | Select-Object -First 1
    }
  




$MItems = @();

Get-ChildITem "$Mshare\*.csv" | ForEach-Object{
    $MItems += Import-Csv $_ | Where-Object {$_.serial -ne ""}
    }



## Progress 
$count = 0
$total = (($witems).count + ($mitems).count)


$SnipeLocations = Get-snipeitlocation -limit 99999 | Select-Object Id,Name
$SnipeModels = Get-Model | Select-Object Id,model_number
$AllAssets = Get-Asset -limit 99999
$MonitorTags = Import-Csv $TagFile

$results = @();



foreach($witem in $witems){
$AssetActions =@()
$Comments = @()
$lineout = @()
$wbuildparms = @{}
$BuildCustomFields = @();

$statusid = [int]"2"
$SnipeAsset = ""
$locationid = ""
$model = ""

Write-Progress -Activity "Processing Workstation: $($witem.'Asset: Name')" -PercentComplete ($count / $total * 100)
$count++

$Notes = @"
[Last Seen]: $($Witem.'Inventory: Timestamp')
[Last User]: $($Witem.'OS: Last User')
[OS]: $($Witem.'OS: Name')
[OS Install]: $($Witem.'OS: Install Date')
[Ram]: $($witem.'Specs: Physical Ram')
[HDD]: $($witem.'Specs: Total Disk Space')
[MAC]: $($witem.'Network: Ethernet Mac Address')
[Wi-Fi MAC]: $($witem.'Network: Wireless MAC Address')
"@



$SnipeAsset = $AllAssets | Where-Object {$_.asset_tag -eq $witem.'Asset: Tag'}
$currentLocation = Get-LocationNameFromIP $witem.'Network: IP Address'

If($SnipeAsset){
    ### Actions on updating an ASSET ### 
    $AssetActions += "Update"
    $wbuildparms += @{
        "id" = [int]$SnipeAsset.id
        "name" = $SnipeAsset.asset_tag
    }

    ## Verify Model Number is the same 
    if($SnipeAsset.model_number -ne $Witem.'Asset: Model Number'){
        $AssetActions += "Model Mismatch"
        $Comments += "Model number mismatch - please remove $($witem.'Asset: Tag') : $($witem.'Asset: Model Number') from inventory"
        continue;
    }else{
        $wbuildparms += @{
            "model_id" = $SnipeAsset.model.id
        }
    }

    if($SnipeAsset.Notes -ne $notes){
        $AssetActions += "Updated Notes"
    }

    if($SnipeAsset.location.name -ne $currentLocation){
        $locationid = $snipeLocations | Where-Object {$_.Name -eq $CurrentLocation} | select-object -ExpandProperty id
        if($locationid){
            $AssetActions += "Update Location"
            $buildCustomFields += @{
            "location_id" = $locationid
            }
        }else{
            $Comments += "IP Address $($witem.'Network: IP Address') or location $currentLocation not known"
        }
        
    }

    $wbuildparms += @{
        'customfields' = $BuildCustomFields
    }


    if($AssetActions[1]){
    try{
        Set-Asset -id $($wbuildparms.id) -Model_id $($wbuildparms.model_id) -Status_id $statusid -Name $($wbuildparms.name) -customfields $($wbuildparms.customfields) | Out-Null
        $AssetActions += "Updated Asset"
    }catch{
        $Comments += "Failed to Set Asset"
        $comments += $error[0]
        }
    }else{
        $AssetActions = "No change"
    }
    
    $lineout = [PSCustomObject]@{
        "Asset" = $($wbuildparms.name)
        "Asset ID" = $($wbuildparms.id)
        "Assigned"= $($SnipeAsset.Assigned_to.name)
        "Comments" = $($Comments -join "|")
        "Actions" = $($AssetActions -join "|")
    }   
    $results += $lineout
}else{

    ### Actions on a NEW ASSET ###
    $AssetActions += "New"
    $wbuildparms = @{
        'name' = $witem.'Asset: Name'
        'tag' = $witem.'Asset: Tag'
        'status_id' = $statusid
    }

    $model = $SnipeModels | Where-Object {$_.model_number -eq $witem.'Asset: Model Number'}
    if(-not($model))
    {   
        $AssetActions += "No Model"
        $Comments += "Model $($witem.'Asset: Model Number') not in Snipe Models"
        $lineout = [PSCustomObject]@{
            "Asset" = $($wbuildparms.name)
            "Asset ID" = $($wbuildparms.id)
            "Comments" = $($Comments -join "|")
            "Actions" = $($AssetActions -join "|")
        } 
        $results += $lineout
        continue
    }

    $locationid = $snipeLocations | Where-Object {$_.Name -eq $CurrentLocation} | 
            select-object -ExpandProperty id
    $Comments += "Setting Initial Default location to current location"


    $buildCustomFields = @{
        'notes' = $Notes
        'location_id' = $locationid
        'rtd_location' = $locationid
        'serial' = $witem.'Asset: Serial Number'
        
    }

    $wbuildparms += @{
        'model_id' = $model.id
        'customfields' = $BuildCustomFields
    }
    
    try{
        New-Asset -name $($wbuildparms.tag) -tag $($wbuildparms.tag) -model_id $($wbuildparms.model_id) -Status_id $($wbuildparms.status_id) -customfields $($wbuildparms.customfields) | Out-Null
        $AssetActions += "Created Asset"
    }catch{
        $Comments += "Failed to create Asset: $($wbuildparms.tag)"
        $comments += $error
        }
    }
    $lineout = [PSCustomObject]@{
        "Asset" = $($wbuildparms.name)
        "Asset ID" = $($wbuildparms.id)
        "Comments" = $($Comments -join "|")
        "Actions" = $($AssetActions -join "|")
    }   
    $results += $lineout

}

foreach($mitem in $mitems){

    $AssetActions =@()
    $Comments = @()
    $lineout = @()
    $mbuildparms = @()
    $mBuildCustomFields = @()
    $statusid = [int]"2"
    $SnipeAsset = ""
    $ParentAsset = ""
    $locationid = ""
    $model = ""
    $TagNumber = ""

    $Notes = @"
[Last Seen]: $($mitem.'Last Seen')
"@
Write-Progress -Activity "Processing Monitors of: $($mitem.'Attached To')" -PercentComplete ($count / $total * 100)
$count++

$SnipeAsset = $AllAssets | Where-Object {$_.serial -eq $mitem.Serial}

$TagNumber = $MonitorTags | Where-Object {$_.serial -eq $mitem.serial } | Select-Object -ExpandProperty tag -First 1


if(-not($TagNumber)) {
    $TagNumber = $mitem.Serial
    $Comments += "Missing SerialToTag"
}else{
        $Comments += "Found SerialToTag"
}
        $mbuildparms += @{
            'name' = $TagNumber
        }


$ParentAsset = $AllAssets | Where-Object {$_.asset_tag -eq $mitem.'Attached To'}


## Logic on FOUND item
if($SnipeAsset) { 
        $AssetActions += "Update"
        $Comments += "Found Asset"
               
        $mbuildparms += @{
            "id" = [int]$SnipeAsset.id
            "model_id" = $SnipeAsset.model.id
        }

        if($notes -ne $SnipeAsset.notes){
            $AssetActions += "Update Notes"

        }
        
        if($ParentAsset.id -ne $SnipeAsset.assigned_to.id){
            $AssetActions += "Update Parent"
        }
        $mbuildCustomFields = @{
            'notes' = $Notes
            'serial' = $mitem.serial
            'assigned_asset' = $ParentAsset.Id
            'asset_tag' = $TagNumber
            
        }
        $mbuildparms += @{
            'customfields' = $mBuildCustomFields
        }

        try{
            set-Asset -id $($mbuildparms.id) -name $($mbuildparms.name) -model_id $($mbuildparms.model_id) -Status_id $statusid -customfields $($mBuildparms.customfields) | Out-Null
            $AssetActions += "Updated Asset"
        }catch{
            $Comments += "Failed to update Asset: $($mbuildparms.asset_tag)"
            }

    }else{

        $AssetActions += "New"

    
        $model = $SnipeModels | Where-Object {$_.model_number -eq $mitem.'Model'}
        if(-not($model))
        {   
            $AssetActions += "No Model"
            $Comments += "Model $($mitem.'model') not in Snipe Models"
            $lineout = [PSCustomObject]@{
                "Asset" = $($mbuildparms.name)                
                "Assigned" = $($mitem.'Attached To')
                "Comments" = $($Comments -join "|")
                "Actions" = $($AssetActions -join "|")
            } 
            $results += $lineout
            continue
        }
    
        $mbuildCustomFields = @{
            'notes' = $Notes
            'serial' = $mitem.serial
            'assigned_asset' = $ParentAsset.Id
            
        }
    
        $mbuildparms += @{
            'model_id' = $model.id
            'customfields' = $BuildCustomFields
            'status_id' = $statusid
        }
        
        try{
            New-Asset -name $($mbuildparms.name) -tag $TagNumber -model_id $($mbuildparms.model_id) -Status_id $($mbuildparms.status_id) -customfields $($mbuildparms.customfields) | Out-Null
            $AssetActions += "Created Asset"
        }catch{
            $Comments += "Failed to create Asset: $($mbuildparms.name)"
            }
        }
        $lineout = [PSCustomObject]@{
            "Asset" = $($mbuildparms.name)
            "Asset ID" = $($mbuildparms.id)
            "Comments" = $($Comments -join "|")
            "Assigned" = $($ParentAsset.asset_tag)
            "Actions" = $($AssetActions -join "|")
        }   
        $results += $lineout
    
    }

    
$results
$results | Export-Csv log.csv -NoTypeInformation -Force


###########  CopyPasta ###########
