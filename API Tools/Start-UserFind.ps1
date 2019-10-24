$HostName = "ServerName"

Import-Module Polaris

New-PolarisRoute -Path /findme -Method GET -Scriptblock {
    
    if ($Request.Query['user']) {
        $q = $Request.Query['user']

            if($q -match '^CN=')   {
                $r = ([adsi]("LDAP://$q")).Properties
            } elseif ($q -match '([a-zA-Z\-]+\s?\b){2,}'){
            $r = ([adsisearcher]("CN=$q")).FindOne().Properties
            
            }else {
            $r = ([adsisearcher]("samAccountName=$q")).FindOne().Properties    
            }

            $title = $r.title
            $email = $r.mail
            $boss = $r.manager
            $name = $r.displayname
            $branch = $r.description

        $boss = ([adsi]("LDAP://$boss")).Properties
            $bossemail = $boss.mail
            $bossTitle = $boss.title
            $bossname = $boss.name

        $qmanager = @{
            "title" = "$bosstitle"
            "name" = "$bossname"
            "email" = "$bossemail"
        }

        $qresponse = @{
            "title" = "$title"
            "name" = "$name"
            "email" = "$email"
            "manager" = $qmanager
            "branch" = "$branch"
        } | ConvertTo-Json

        $Response.Send($qresponse)
    } else {
        $response.send("Try again, friends.")
    }
}

Start-Polaris -Port 5000 -HostName $HostName
