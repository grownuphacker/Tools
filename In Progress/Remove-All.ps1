Function Get-UninstallString
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$Application
    )
$uninstalls = (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -match $application } | Select-Object -Property DisplayName, UninstallString).UninstallString
return $uninstalls
}
