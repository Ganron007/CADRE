$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

$scriptContent = @'
$out = 'WT039_PROOF ' + (whoami) + ' | ' + (hostname) + ' | ' + (Get-Date -Format o)
Set-Content -Path 'C:\Shares\vault\wt039-proof.txt' -Value $out -Force
whoami
'@

Write-Output "=== SMS_Scripts.CreateScripts ==="
$class = New-Object System.Management.ManagementClass($scope, "SMS_Scripts", $null)
$in = $class.Methods["CreateScripts"].InParameters
$in["ScriptName"] = "CADRE-WT039-SiteTakeover"
$in["Script"] = $scriptContent
$in["ScriptType"] = [uint32]1
$in["Timeout"] = [uint32]120
$in["ApprovalState"] = [uint32]1
$in["Approver"] = "range\svc_sccm"
$in["Author"] = "range\svc_sccm"
$in["ScriptDescription"] = "CADRE Branch C WT039 site takeover proof"
$in["Comment"] = ""
$in["ParameterlistXML"] = ""
$in["ParamsDefinition"] = ""
$in["ScriptGuid"] = ""
$in["ScriptVersion"] = ""
try {
    $ret = $class.InvokeMethod("CreateScripts", $in, $null)
    Write-Output "RETURN_VALUE=$($ret.ReturnValue)"
    Write-Output "SCRIPT_GUID=$($ret['ScriptGuid'])"
    Write-Output "SCRIPT_ID=$($ret['ScriptID'])"
    Write-Output "RAW_RETURN:"
    $ret | Out-String -Width 200
} catch {
    Write-Output "CREATE_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "DETAILS: $($_.ErrorDetails.Message)" }
}
Write-Output "DONE-CREATE"
