if(Test-Path "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe"){
    $ver32 = (Get-ChildItem "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe").VersionInfo.ProductVersion
    Write-Output "Version: $ver32 32-bit"
}elseif(Test-Path "$env:ProgramFiles\Mozilla Firefox\firefox.exe"){
    $ver64 = (Get-ChildItem "$env:ProgramFiles\Mozilla Firefox\firefox.exe").VersionInfo.ProductVersion
    Write-Output "Version: $ver64 64-bit"
}else{
    Write-Output "Not Installed"
}
# SIG # Begin signature block
# MIIJUQYJKoZIhvcNAQcCoIIJQjCCCT4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUR5X7YxFB7fMa86gHiOaueAcw
# 6LmgggaSMIIGjjCCBXagAwIBAgITHwAARqZTPgkEC60AUwAAAABGpjANBgkqhkiG
# 9w0BAQsFADBwMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEjAQBgoJkiaJk/IsZAEZ
# FgJvbjEWMBQGCgmSJomT8ixkARkWBm9zaGF3YTEUMBIGCgmSJomT8ixkARkWBGNp
# dHkxFTATBgNVBAMTDE9zaGF3YS1UcnVzdDAeFw0xODA3MTIxNDI5MTdaFw0xOTA3
# MTIxNDI5MTdaMIHyMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEjAQBgoJkiaJk/Is
# ZAEZFgJvbjEWMBQGCgmSJomT8ixkARkWBm9zaGF3YTEUMBIGCgmSJomT8ixkARkW
# BGNpdHkxFTATBgNVBAsTDE9zaGF3YSBVc2VyczEbMBkGA1UECxMSQ29ycG9yYXRl
# IFNlcnZpY2VzMSwwKgYDVQQLEyNJbmZvcm1hdGlvbiBhbmQgVGVjaG5vbG9neSBT
# ZXJ2aWNlczEcMBoGA1UECxMTQ29tcHV0ZXIgT3BlcmF0aW9uczEXMBUGA1UEAxMO
# QWRhbSBBYmVybmV0aHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC2
# NeU1t38jXy/9gdbEfzjxEfXPkrV4Dvn/35ogJF5j0DC3iQ0Cs5LcvzM+MIwbj0jJ
# BkbEK76ajil5WCYFY/5CvDf0hMh8ux7Qt9AZm50yqTZd/L1waaUHvtzwS5YL1fBB
# pfjhKKSz+quWVUFmO++otORelAAD4GlsXNHCLzWe7gcM0a42Sw2NHxz8U3wagK4E
# ykn+QZwShiZPGwSr9Uf/550mk+yJpVr1X3b/sDICGp1desoQz2O5A86/JXpuND/Q
# Xo0Giy+PMIfEEx6zy3GMqygVRKIIZqTzo8xlD8y1lEfIssjkFDxGg0eLyt2VF88p
# mjW+7RpYav8NrvacjXy9AgMBAAGjggKcMIICmDA9BgkrBgEEAYI3FQcEMDAuBiYr
# BgEEAYI3FQiH0aZ7he6OHcWZB4Oq33CD+dFCgS+FxNImhrO/TgIBZAIBCzATBgNV
# HSUEDDAKBggrBgEFBQcDAzALBgNVHQ8EBAMCBeAwGwYJKwYBBAGCNxUKBA4wDDAK
# BggrBgEFBQcDAzAdBgNVHQ4EFgQUFMZiCxjFV3r6+W24H58BTMFm+d0wHwYDVR0j
# BBgwFoAUcvHXXLMZV+3jAyqpQf6HTkC9vG4wgdYGA1UdHwSBzjCByzCByKCBxaCB
# woaBv2xkYXA6Ly8vQ049T3NoYXdhLVRydXN0LENOPXZzQ0EsQ049Q0RQLENOPVB1
# YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRp
# b24sREM9Y2l0eSxEQz1vc2hhd2EsREM9b24sREM9bG9jYWw/Y2VydGlmaWNhdGVS
# ZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBv
# aW50MIHNBggrBgEFBQcBAQSBwDCBvTCBugYIKwYBBQUHMAKGga1sZGFwOi8vL0NO
# PU9zaGF3YS1UcnVzdCxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMs
# Q049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1jaXR5LERDPW9zaGF3YSxE
# Qz1vbixEQz1sb2NhbD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2Vy
# dGlmaWNhdGlvbkF1dGhvcml0eTAvBgNVHREEKDAmoCQGCisGAQQBgjcUAgOgFgwU
# YWFiZXJuZXRoeUBvc2hhd2EuY2EwDQYJKoZIhvcNAQELBQADggEBADR6a3XeJu8N
# aPEl+39ZZ1ZhAK3yt+8hyazzFntXR4v+Jv4pWbOMXDKvkqEUBwWbNdAB+mwnifoD
# vRXgUL9buXaXI0NRI0cWi2DEOsC9GtPfoi2Bfiz0N2zKDt+hZj8TBSYWGNksL1Y2
# wP4Npm9PSbQyrDmwrF11/b8hywMFqIw9uXvJqBtkoSmPO3OxNICspFmDq3fPL/Ie
# AaMRizI0T9YBUnSxzY1C8Yq+pK1WDjOMsRZdp3hmbiSaEXipPqcljNw3jzAif3cQ
# Jx6TqKQoXnoHDoVTttll+fICWHOuq+jcz/Wwt93ONaxI7nJ+OmIEX9RuxQGyw01g
# WNiqEb5569YxggIpMIICJQIBATCBhzBwMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwx
# EjAQBgoJkiaJk/IsZAEZFgJvbjEWMBQGCgmSJomT8ixkARkWBm9zaGF3YTEUMBIG
# CgmSJomT8ixkARkWBGNpdHkxFTATBgNVBAMTDE9zaGF3YS1UcnVzdAITHwAARqZT
# PgkEC60AUwAAAABGpjAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAA
# oQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4w
# DAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUnOjgLdMcZbH2E3Tct0FJC2yv
# G9swDQYJKoZIhvcNAQEBBQAEggEArPo1hC58lZFLjXUbyod0Ut+VCHyCYATdMXEl
# Y5+MslejXtHow7HJSRdpY1NRneve3Gms634G/VqlDCeoGX9G0XuBs8DFj0yMq4J0
# jx3HJjDyPT2TKUMRfF6vBjetM5GRyyZX0VFnYqkQpzMyciih5O3VxFEJjtyHdKrq
# uQRlD7r6NZNZWh3z+ShL+9zKaFFzXy6fyA3Yzx1mNwgl9NEPPKWJ6CvqPoU0w7PB
# 6/p0L/Y4i/hV269+lucYpeau7FhB9sL2lb9Doxm4HT3rb17ZKEpbkhYzyTx0ItKy
# yRHnS6j+qNlziOjpFosFWSIdK6u4+G5MiQEnhmlaMm1LYi+obA==
# SIG # End signature block
