if(Test-Path "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe"){
    $ver32 = (Get-ChildItem "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe").VersionInfo.ProductVersion
    Write-Output "Version: $ver32 32-bit"
}elseif(Test-Path "$env:ProgramFiles\Mozilla Firefox\firefox.exe"){
    $ver64 = (Get-ChildItem "$env:ProgramFiles\Mozilla Firefox\firefox.exe").VersionInfo.ProductVersion
    Write-Output "Version: $ver64 64-bit"
}else{
    Write-Output "Not Installed"
}
