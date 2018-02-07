<#

.NOTES
Author:      Adam "Abe" Abernethy
Twitter:     @ReallyBigAbe
Go here:     https://blueteam.ninja
  
Don't be a mean person. 

.SYNOPSIS

Scans all the shares on a given server and dumps out a report. 

.DESCRIPTION

A report of the contents of a File Server, with some basic extension categorizations. 
Basically - import this report into PowerBI and get a really cool look at what stored on a Fileshare. 

If you don't send any parameters, you'll get the local system.

.PARAMETER ReportPath

A location to save the Reports created for each share

.PARAMETER Server

The File Server(s) to unleash the madness on. 


.INPUTS

None. Not pipeable at this time. 

.OUTPUTS

The output from the scan, grouped by extension. 

.EXAMPLE

C:\PS> Get-FileShareReport -Server LUNARSERVE -ReportPath C:\Visualizations\LUNARSERVE



#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)] 
        [string]$ReportPath,
    [Parameter(Mandatory=$false)]
        [string]$fileserver
)

if(!$fileserver){
    $fileserver = $env:COMPUTERNAME
}

if(-not(Test-Path $reportpath\*)){
Write-Verbose "Report Path didn't make it, so a delice sledgehammer will forge it for you."
New-Item -ItemType Directory -Path (Join-Path $reportpath (get-date -format dd.MM.yyyy))
}

#Archive existing reports, or just toss everything in that folder over and OWN it.  MINE
Move-Item $reportpath\* "$reportpath\Archive_(get-date -format dd.MM.yyyy)" -Force -ErrorAction SilentlyContinue

$results = @()

$fsharedrivelist = Get-WmiObject -Class Win32_share -ComputerName $fileserver -filter "Type=0" | Select-Object @{Name='Path';e={"\\"+$fileserver+"\" + $_.name}},Name

    foreach($fshare in $fsharedrivelist){

        $fshareOwner = $fshare.Name
        Write-Progress -Activity "Indexing Files of $fshareOwner" -Status "Reading Files"
        
        $filename = $reportpath +  "\" + $fshare.Name + ".csv"
        
        $files = @()
        
        $files = Get-ChildItem $fshare.Path -Recurse -File | Select Basename,extension,Length,LastWriteTime
        

               
        foreach($file in $files){
        $currentfilename = $file.BaseName
        Write-Progress -Activity "Analyzing Files of $fshareOwner" -Status "Processing $currentfilename"
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
Write-Verbose "Category is $TypeCategory"
            $LineOut = New-Object -Type PSObject -Property @{
            #Name = $file.BaseName
            'Age (Days)' = $Age
            Extension = $Type
            Category = $TypeCategory
            Branch = $fshareOwner
            Size = $Size
        }

Write-Verbose "Age $Age Extension $Type Category $TypeCategory  Branch $fshareOwner Size $Size"

        $results += $LineOut
        } 
        
        Write-Output "Summary of $fshareOwner"
        Write-Output "-----------------------"
        $results | Group-Object Category | ForEach-Object {
            New-Object -Type PSObject -Property @{
                "Category" = ($_.Group | Select-Object -Unique Category).Category
                "Sum" = [math]::Round((($_.Group | Measure-Object Size -sum).Sum/1MB),1).ToSTring() + " MB"
        }
    } | Format-Table -AutoSize
    
        Write-Verbose "Saving the file now"
        $results | Export-Csv $filename -NoTypeInformation
}


