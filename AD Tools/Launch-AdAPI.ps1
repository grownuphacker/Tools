New-PolarisRoute -Path /findme -Method GET -Scriptblock {
    if ($Request.Query['user']) {
        $q = $Request.Query['user']
        $r = ([adsisearcher]("samAccountName=$q")).FindOne().Properties
            $title = $r.title
            $email = $r.mail
            $boss = $r.manager
            $name = $r.displayname

        $boss = ([adsisearcher]("distinguishedName=$boss")).FindOne().Properties
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
        } | ConvertTo-Json
        $Response.Send($qresponse)
    } else {
        $Response.Send('Hello World')
    }
}
