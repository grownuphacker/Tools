param(
    [string]$ADDRESS, # Your NVR or Camera IP Address
    [string]$USER, # Your username
    [string]$PASS, # Your password
    # Insert warning about ensuring you don't bake admin credentials into a script
    # Behave yourself
    # Big Abe is watching you...
    [bool]$DEBUG=$false
)

$URL = "https://$($ADDRESS)/cgi-bin/api.cgi"
$TOKEN = "null"

function Invoke-RlLogin {
    Invoke-RlApi -CMD 'Login' -PARAM @"
{
    "User": {
        "userName": "$USER",
        "password": "$PASS"
    }
}
"@
}

function Invoke-RlApi {
    param(
        [string]$CMD,
        [string]$PARAM = '{}'
    )

    $REQ = @{
        cmd = $CMD
        action = 0
        param = (ConvertFrom-Json $PARAM)
    } | ConvertTo-Json

    $TGT = "{0}?cmd={1}&token={2}" -f $URL, $CMD, $TOKEN
    
    if ($DEBUG) {
        ">>> REQUEST >>>"
        "TARGET: $TGT"
        ($REQ | ConvertFrom-Json) | ConvertTo-Json -Depth 10
    }

    $RES = Invoke-RestMethod -Method 'POST' -ContentType 'application/json' -Body "[$REQ]" -Uri $TGT

    if ($DEBUG) {
        "<<< RESPONSE <<<"
        ($RES | ConvertFrom-Json) | ConvertTo-Json -Depth 10
    }

    if ($RES[0].code -eq 0) {
        $RES[0].value
    } else {
        Write-Error "$CMD ERROR: $($RES[0].error.detail) ($($RES[0].error.rspCode))"
    }
}

function Invoke-RlLogin {
    Invoke-RlApi -CMD 'Login' -PARAM @"
{
    "User": {
        "userName": "$USER",
        "password": "$PASS"
    }
}
"@
}

function Invoke-RlLogout {
    if ($TOKEN -eq "null" -or $TOKEN -eq "") { return }
    Invoke-RlApi -CMD 'Logout'
}

$TOKEN = Invoke-RlLogin

if (-not $TOKEN) { exit 1 }

try {
    $scriptArgs = $args.Clone()
    while ($scriptArgs) {
        $CMD = $scriptArgs[0]
        $scriptArgs = $scriptArgs[1..($scriptArgs.Length - 1)]

        if ($scriptArgs -and ($scriptArgs[0] -match '[{}]')) {
            $PAYLOAD = $scriptArgs[0]
            $scriptArgs = $scriptArgs[1..($scriptArgs.Length - 1)]
        } else {
            $PAYLOAD = '{}'
        }

        Invoke-RlApi -CMD $CMD -PARAM $PAYLOAD
    }
}
finally {
    Invoke-RlLogout
}
