[CmdletBinding()]
Param(
    [Parameter()]
        [int]$MaxGroupSize = 5,
    [Parameter()]
        [int]$MaxInteractions = 30, 
    [Parameter()]
        [string]$NodeFile = "nodes.csv", 
    [Parameter()]
        [int]$daysOfData = 30,
    [Parameter()]
        [int]$infectionPeriod = 5
)

$Nodes = Import-Csv "$($PSSCriptRoot)\$($NodeFile)"
$nodeCount = $nodes.Count


function Get-Infected{
    param ($testNode)
    Write-Verbose "Checking infection against $testNode"
    if($testNode -in $global:infectedList.Source){
        return $true
    }else {
        return $false
    }

}

Function Set-Infected{
    Param(
        [Parameter()]
            $sourceNode,
        [Parameter()]
            [int]$infectionPeriod
    ) 
    
    Write-Verbose "Infecting $SourceNode for $"
    $global:infectedList += [PSCustomObject]@{
        Source = $sourceNode 
        DaysRemaining = $infectionPeriod
    }
    
}
Function Invoke-NoninteractiveInfections{
    Param(
        [Parameter()]
            $dailyList,
        [Parameter()]
            [int]$today
    ) 
        $r = $global:infectedList.source | ForEach-Object {if($_ -notin $dailyList){Write-Output "$($_) 1"}}
        return $r
        
}
Function Invoke-DailyReduction{ 
    # Holy Gadzooks - Scriptblocks as variables for the win
    # Seriously, the line below this comment is pure voodoo.  I love it. 
    $ReducebyOne = {$_.DaysRemaining--}
    $newInfectedList = @()
    # Boom - I just script
    $global:infectedList | ForEach-Object $ReducebyOne
    foreach ($infected in $global:infectedList){
        Write-Verbose "Checking $infected"
        if ($infected.DaysRemaining -gt 0){
        $newInfectedList += $infected
        Write-Verbose "Assignined $infected to $newInfectedList"
        }

    }
    $global:infectedList = $newInfectedList
    Write-Verbose "Infection List: $global:infectedList"
    
    
}   


Write-Verbose "Randomly assigning 10% of the population with Infection of varying remaining times"
$global:infectedList = @()
$sampleInfections = Get-Random -Maximum $nodeCount -Count ($nodeCount *0.1)
    
$global:infectedList += foreach($sample in $sampleInfections){
     [PSCustomObject]@{
        Source = $sample 
        DaysRemaining = (Get-Random -Maximum $infectionPeriod -Minimum 1)
    }
}


$dayResult = @()
$result = foreach($day in 1..$daysOfData){
    Write-Host $global:infectedList

    Write-Verbose "Simulating day $day`n"
    $interactions = Get-Random -Maximum $MaxInteractions
    $dayResult = foreach($interaction in 0..$interactions){
        $groupSize = Get-Random -minimum 2 -Maximum $MaxGroupSize
        $line = Get-Random -Maximum $nodeCount -count $groupSize
        $sourceNode = $line[0]
        Write-Debug "Checking $sourceNode for infection"
        
            if(Get-Infected $sourceNode) {
                $lineInfectedstate = 1
                #Randomly infect any of the random interactions that day
                try{
                    $z = $line[1..$line.count] | Get-Random -Count (Get-Random -Maximum $line.count)
                    $z | foreach-Object { Set-Infected -sourceNode $_ -infectionPeriod ($infectionPeriod+1) }
                }catch{ Write-Debug "Lucky, no infections today" }
            }else{ 
                $lineInfectedstate = 0
            }

        Write-Output "$($line[0]) $lineinfectedstate $($line[1..$line.count])"

}
Invoke-DailyReduction

if($global:infectedList.count -ne 0){
$dayresult += Invoke-NoninteractiveInfections -dailyList $dayresult -today $day
}

$dayresultcsv = $dayresult -replace(' ',',')


$dayresultcsv
Write-Verbose -Message "$dayresultcsv"
$dayresultcsv | out-file -FilePath "$($PSSCriptRoot)\day_$($day).csv"

Write-Verbose "Day $day Infections`n`n=============`n"
$global:infectedList | Format-Table | Out-String | Write-Verbose

}

#Write-Output $result