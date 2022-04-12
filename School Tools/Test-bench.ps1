

$MaxGroupSize = 5
$Interactions = 10
$result =@{}

$result = foreach($interaction in 1..$interactions){
        $groupSize = Get-Random -minimum 2 -Maximum $MaxGroupSize
        $line = Get-Random -Maximum 50 -count $groupSize
        Write-Output "$line`n"
}

Write-Output "$result"
