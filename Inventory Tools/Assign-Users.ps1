$SnipeURL = "https://snipeit.domain.com"
$SCCMSiteName = "DEF"
$SCCMServer = "SCCM.local"
$SCCMDefaultInstallUser = "Administrator"


try{
    #Put the API key in a text file in teh same folder as this script to make life easy.  
    #Handle permissions with care. 
    #do not folder or bend.

    $SnipeAPI = Get-content "$PSScriptRoot\key.txt"
    Set-Info -url $SnipeURL -apiKey $SnipeAPI -ErrorAction Stop
}catch{
    #I use this for SCCM Exit codes
    #I also lean on POSIX error codes because I'm a greybeard and wokefulness is lit, fam.
    return 126;
    
}

function Get-SCCMPCInfo {
    param (
        [string]$SiteName,
        [string]$SCCMServer=
    )

 
  
        #Inventory Query
        $query = @"
            SELECT
            A.[Manufacturer00] AS Make
            ,A.[Model00] AS Model
            ,A.[Name00] AS AssetTag
            ,A.[UserName00] AS PrimaryUser
            ,B.[SerialNumber00] AS Serial
            ,C.[DefaultIPGateway00] AS Network
            FROM [CM_OSH].[dbo].[Computer_System_DATA] A, 
                [CM_OSH].[dbo].[PC_BIOS_DATA] B, 
                [CM_OSH].[dbo].[Network_DATA] C
            WHERE A.[MachineID] = B.[MachineID] 
                AND A.[MachineID] = C.[MachineID] 
                AND C.[DefaultIPGateway00] IS NOT NULL;
"@

            Write-Progress -Activity "Querying SCCM SQL DB to PC Information"
            Import-Module SQLSERVER

            $SCCMPCData = Invoke-SQLCMD -server $SCCMServer -Database "CM_$SiteName" -Query $query | Where-Object {$_.Make -notlike "Vmware, Inc."}
    return $SCCMPCData
}



$Assets = Get-SCCMPCInfo -SiteName $SCCMSiteName -SCCMServer $SCCMServer  | Where-Object {($_.PrimaryUser -notlike "*${SCCMDefaultInstallUser}*") -and ($_.PrimaryUser -notlike "")}
$SnipeAssets = get-asset -limit 9999
$snipeUsers = get-user -limit 9999
$results = @();

foreach($asset in $assets){
    $user = ""
    $serial = ""
    $snipeUserID = ""

    $user = $asset.PrimaryUser.split('\')[1]
    $serial = $asset.Serial
    
    $snipeUserID = $snipeUsers | Where-Object {$_.username -eq $user} | Select-Object -expandproperty id

    if(-not($serial -in $SnipeAssets.serial)){
        $lineout = [PSCustomObject]@{
            'Asset' = $asset.AssetTag
            'Serial' = $serial
            'User' = $user
            'Action' = "Skipping...Serial Not Found"
        }
        $results += $lineout;
        continue;
    }else{
        $snipeAsset = $snipeAssets | Where-Object{$_.serial -eq $serial}
    }

    
    if(-not($SnipeUserID)) {
        $lineout = [PSCustomObject]@{
            'Asset' = $asset.AssetTag
            'Serial' = $serial
            'User' = $user
            'Action' = "Skipping...User ID Not Found"
        }
        $results += $lineout;
        continue;
    }elseif($snipeAsset.assigned_to.username -eq $user){
        $lineout = [PSCustomObject]@{
            'Asset' = $asset.AssetTag
            'Serial' = $serial
            'User' = $user
            'Action' = "No Change"
        }
        $results += $lineout;
        continue; 
    }else{

       $BuildParms = @{
            'id' = $snipeAsset.id
            'model_id' = $snipeAsset.model.id
        }
    
        try{

            # Clear first - because I filled 'assigned_to' fields with garbage by accident

            set-asset -id $BuildParms.id -Model_id $BuildParms.model_id -Status_id 2 -customfields  @{'assigned_to'='';'checkout_to_type'=''} -ErrorAction Stop | Out-Null
            Set-ASsetOwner -id $buildparms.id -assigned_id $SnipeUserID -checkout_to_type 'user'
            
            $lineout = [PSCustomObject]@{
                'Asset' = "$($asset.AssetTag) [$($snipeAsset.model_id)]"
                'Serial' = $serial
                'User' = "${user} [${SnipeUserID}]"
                'Action' = "Updated"
            }
            $results += $lineout;

        }catch{
            $lineout = [PSCustomObject]@{
                'Asset' = $asset.AssetTag
                'Serial' = $serial
                'User' = $user
                'Action' = "Failed:" + $error[0]
            }
            $results += $lineout;
        }

    }

    
}
$results | Export-Csv asset-owners.csv -NoTypeInformation -Force

