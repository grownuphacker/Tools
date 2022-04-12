[CmdletBinding()]
Param(
    [Parameter()]
        [int]$MaxGroupSize = 5,
    [Parameter()]
        [int]$MaxInteractions = 30, 
    [Parameter(Mandatory=$true)]
        [string]$NodeFile, 
    [Parameter()]
    [int]$daysOfData = 20

)


$Nodes = Import-Csv $NodeFile
$nodeCount = $nodes.count
$result =@{}
$dayResult = @{}
$result = foreach($day in 1..$daysOfData){
$interactions = Get-Random -Maximum $MaxInteractions
Write-Output "Day $day generated `n"
$dayResult = foreach($interaction in 0..$interactions){
        $groupSize = Get-Random -minimum 2 -Maximum $MaxGroupSize
        $line = Get-Random -Maximum $nodeCount -count $groupSize
        Write-Output "$line"
}

$dayresultcsv = $dayresult -replace(' ',',')
$dayresultcsv | out-file -FilePath "day_$($day).csv"

}
Write-Output "$result"