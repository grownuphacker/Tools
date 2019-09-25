    $reportpath ="E:\UserDiskReports\"
    $fileserver = "SRV_USERSHARE"

<#
$RunDate = Get-Date -format MM-dd-yyyy
$FullPath = ($reportpath + "\" + "Archive\" + $RunDate)
New-Item $FullPath -ItemType Directory -Force
Move-Item $reportpath\* $FullPath
#>

## This works as long as its all at the Root of the share eg. \\SRV_USERSHARE\BossMan$\  -- Modify the Path expression in the next line if not
$shareList = Get-WmiObject -Class Win32_share -ComputerName $fileserver -filter "Type=0" | Select-Object @{Name='Path';e={"\\"+$fileserver+"\" + $_.name}},Name

## REsuming a broken instance
## Run the above two actual lines of code (not including comments) as a selection - trim the CSV from wherever you cancncelled or broke your universe
## THen run $shareList | Export-Csv E:\resume.csv -notypeinformation -noclobber
#
##  Then just import it below and resume your daily dose of Awesomeness.
#$sharelist = Import-Csv "E:\resume.csv"


#Progress Indicator
$total = ($shareList).Count
$counter = 0
$results = @();

    foreach($share in $sharelist){
        $shareResults =@()
        $counter++
        $userdetails= $null
        $shareName = $share.Name.split('$')[0]
        
        Write-Progress -Activity "Indexing Files of $ShareName" -Status "Reading Files" -PercentComplete ($counter/$total *100) -ID 1
        
        try {
            $userdetails = ([adsisearcher]("samAccountName=$shareName")).FindOne().Properties
            if($userdetails)
            {
                $userbranch = [string]$userdetails.physicaldeliveryofficename
                $username = [string]$userdetails.displayname
                $userdepartment = [string]$userdetails.department

            }
        }catch { 
            $userBranch = "Unknown"
            $username = "Unknown"
            $userdepartment = "Unknown"
        }
        
        
        
        $files = Get-ChildItem $share.Path -Recurse -File -ErrorAction SilentlyContinue| Select-object Basename,extension,Length,LastWriteTime,FullName
        
            $subtotal = ($files).Count
            $subcounter = 0

        foreach($file in $files){
            
            $lineout = @()

            $filePath = $file.FullName
            $subcounter ++;
        $currentfilename = $file.BaseName
        Write-Progress -Activity "Analyzing Files of $shareName owned by $userName" -Status "Processing $currentfilename" -PercentComplete ($subcounter / $subtotal * 100) -ParentId 1
        $Age = ((Get-Date) - $file.LastWriteTime).Days
        $Type = [string]($file.Extension).split(".")[1]
        Write-Verbose "File extension is: $Type"
        $Size = $file.Length
            Switch -regex($Type)
            {
                {$Type -match '(doc?|dot?|xlk?|xls?|xlt?|xlm?|xla?|xll?|xlw?|ppt?|pot?|ppa?|pps?|sld?|acc?|pub|pdf|txt|csv|mpp|tsv|tab)'}  {$TypeCategory = "Office";break}
                {$Type -match '(msg|pst|ost|eml)'}    {$TypeCategory = "Email";break}
                {$Type -match '(gif|jpg|jpeg|tif|png|bmp|jp2|ai|eps|svg|wmf)'}   {$TypeCategory = "Images";break}
                {$Type -match '(7z|zip|rar|cab|gzip|gz|tgz)'} {$TypeCategory = "Archives";break}
                {$Type -match '(shp|shx|dbf|tab|kml|gml|apr|kmz)'}      {$TypeCategory = "GIS";break}
                {$Type -match '(flac|aif?|m4a|wma|mp3|wav|mid|m3u)'}    {$TypeCategory = "Audio";break}
                {$Type -match '(mkv|avi|divx|mov|rm|wmv|mp4|mpg|mpeg|qt)'}    {$TypeCategory = "Video";break}
            default {$TypeCategory = "Other"}

            } 
        
#        $sha1 = (Get-FileHash $filePath -Algorithm sha1).Hash

        $lineout = [PSCustomObject]@{
        AgeDays = $Age
        Extension = $Type
        Category = $TypeCategory
        Share = $shareName
        ShareType = "User"
        UserName = $username
        UserDepartment = $userdepartment
        UserBranch = $userbranch
        Size = $Size
        SizeMB = ($Size)/1MB
        SizeGB = ($Size)/1GB
#        SHA1 = $sha1
        Path = $filePath
        }

        $Shareresults += $lineout
        
        } 

        $Shareresults | Export-Csv "$($reportPath)\$($shareName).csv" -NoTypeInformation -noClobber -force
        $results += $Shareresults
}

$results | Export-Csv "$($reportPath)\_TotalResults.csv" -NoTypeInformation
