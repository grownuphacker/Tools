$app = "java"
Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | 
    Get-ItemProperty | Where-Object {$_.DisplayName -match "$app" } | Select-Object -Property DisplayName, UninstallString | fl
