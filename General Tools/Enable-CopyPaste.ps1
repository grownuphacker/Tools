# Some hack and Glue to enable Copy/Paste -- including GUI options for esx 6.7+
# by Abe
# Do not Fold or Bend

Import-Module VMware.PowerCLI
$server = Read-Host -Prompt "Enter VSphere Server"
Write-Progress -Activity "Connecting"
try{
    $no_visual = Connect-VIserver $server -ErrorAction Stop
}catch [Client20_ConnectivityServiceImpl_Reconnect_SoapException,VMware.VimAutomation.ViCore.Cmdlets.Commands.ConnectVIServer]{
    Write-Output "Access Denied"
    $cr = Get-Credential -Message "Enter VSphere Credentials"
    $no_visual =  Connect-VIServer $Server -Credential $cr -ErrorAction
}
Write-Progress -Activity "Connecting"

$query = Read-Host -Prompt "Server(s) to modify (wildcard OK)"
Write-Progress -Activity "Connecting" -Status "Locating VMs"
$VMs = Get-VM $query
$results = @()
$pr_count = 0
$pr_total = $VMs | Measure-Object | Select-Object -ExpandProperty Count
foreach ($vm in $VMs){
    $pr_count++;
    $currentVM = $vm.Name
    Write-Progress -Activity "Scanning VMs" -Status "Processing: $currentVM" -PercentComplete ($pr_count / $pr_total * 100)
   #Remove the accidental copy.enable line
   $copy = Get-AdvancedSetting -Entity $vm.Name -Name "isolation.tools.copy.disable"
   $paste = Get-AdvancedSetting -Entity $vm.Name -Name "isolation.tools.paste.disable"
   $gui = Get-AdvancedSetting -Entity $vm.Name -Name "isolation.tools.setGUIOptions.enable"

   if($copy) {$no_visual =  Get-AdvancedSetting -Entity $vm.Name -Name "isolation.tools.copy.disable" | Set-AdvancedSetting -Value "FALSE" -Confirm:$false;$ActionCopy ="SET" }else{
    $no_visual = New-AdvancedSetting -Entity $currentVM -Name "isolation.tools.copy.disable" -Value "FALSE" -Confirm:$false;$ActionCopy ="CREATED"
   }
   if($paste) { $no_visual = Get-AdvancedSetting -Entity $vm.Name -Name "isolation.tools.paste.disable" | Set-AdvancedSetting -Value "FALSE" -Confirm:$false;$ActionPaste ="SET" }else{
    $no_visual = New-AdvancedSetting -Entity $currentVM -Name "isolation.tools.paste.disable" -Value "FALSE" -Confirm:$false;$ActionPaste ="CREATED"
   }
   if($gui) { $no_visual = Get-AdvancedSetting -Entity $vm.Name -Name "isolation.tools.setGUIOptions.enable" | Set-AdvancedSetting -Value "TRUE" -Confirm:$false;$ActionGUI ="SET" }else{
    $no_visual = New-AdvancedSetting -Entity $currentVM -Name "isolation.tools.setGUIOptions.enable" -Value "TRUE" -Confirm:$false;$ActionGUI ="CREATED"
   }
$lineout = New-Object PSObject -Property @{
 
    VM          = $currentVM
    Copy        = $ActionCopy
    Paste       = $ActionPaste
    GUI         = $ActionGUI
  } 
   $results += $lineout
}
$results
