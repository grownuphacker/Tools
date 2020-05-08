# Create HTML prepended Disclaimer text based on current organizations Display names
# The original script floating around didn't account for organizations > 300 mailboxes or so.  
# This simply loops through all the mailboxes, breaks it down to a pre-configured segment size 
# and creates transport rules giving them logical labels

# By Abe - chief@blueteam.ninja


## Declare Variables ##


# * * * * IF YOU ONLY READ ONE THING, READ THIS * * * * #
# Set this prefix DIFFERENT than any other rules
# To make it recurring, it deletes the existing rules with the same Prefix without prompt
# Your actions are your own
$RulePrefix = "BEC Alert"
# Remember - Everything under Rule Prefix gets deleted with $RULEPREFIX followed by wildcard


$SubjectPrefix = "CAUTION"
$CodeLocation = "${PSScriptRoot}\content\spoof-alert.html"
$groupsize = 500

# Testing Distribution Group
# This script defaults to only sending to this distribution list
# Look in comments further below to modify when ready for production

$TestGroup = "InformationTechnology@Domain.com"


# OK - Let's begin!!!

Add-PSSnapin  Microsoft.Exchange.Management.PowerShell.SnapIn
$q = Get-Mailbox -ResultSize unlimited | Sort-Object -Property Name | Where-Object {$_.Name -ne ""}
$code = Get-Content $CodeLocation



# # # 
$biglist = 1..($q.count-1)
$counter = [pscustomobject] @{ Value = 0 }
$groups = $bigList | Group-Object -Property { [math]::Floor($counter.Value++ / $groupSize) }
# # # Brilliant code on https://stackoverflow.com/a/26850233  - Thanks Dave Wyatt

Write-Verbose "Remove all rules starting with prefix now..."
Get-TransportRule "${RulePrefix}*" | Remove-TransportRule -confirm:$false

    foreach ($gitem in $groups) {

    # The groups object is an object of numbers
    # Each of those numbers are divided into smaller groups of numbers
    # This looks like a TOTAL goat rodeo, but it is calling the full query of $q at specific locations by how
    # those numbers were divided into chunks. 

    # If you want to see it in action, run this in an ISE on Exchange and call the groups - or insert a Write-Verbose here
    $firstIndex = $gitem.group[0]
    $firstItem = ($q[$firstIndex].Name -split ' ')[0]

    $LastIndex = $gitem.group[($gitem.group.count-1)]
    $LastItem = ($q[$lastIndex].Name -split ' ')[0]
    
       
    $RuleName = "$RulePrefix $FirstItem to $LastItem"
    $RuleData = $q[$firstIndex..$LastIndex].Name

    ### Insert Rule Logic
    $RuleData

    $Rule = @{
        Name = "${RulePrefix}: $firstItem to $LastItem"
        PrependSubject = "${SubjectPrefix}: "
        HeaderMatchesMessageHeader = "From"
        HeaderMatchesPatterns = $RuleData
        FromScope = "NotInOrganization"
        ## To switch to PROD Uncomment this and comment the line 'Testing Distribution List'
        #SentToScope = "InOrganization"
        
        # Testing Distribution List
        SentToMemberOf = $TestGroup

        ApplyHtmlDisclaimerText = "$code"
        ApplyHtmlDisclaimerLocation = "Prepend"

    }

    New-TransportRule @Rule

    }
