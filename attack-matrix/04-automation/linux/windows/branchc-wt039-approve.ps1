$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()
$guid = '200f5731-224e-4c6e-8acc-ef0193e47004'

Write-Output "=== Script instance state ==="
$inst = New-Object System.Management.ManagementObject($scope, "SMS_Scripts.ScriptGuid='$guid'", $null)
try {
    $inst.Get()
    Write-Output ("  Name={0} | Type={1} | Approval={2} | Version={3} | Timeout={4}" -f $inst["ScriptName"], $inst["ScriptType"], $inst["ApprovalState"], $inst["ScriptVersion"], $inst["Timeout"])
} catch {
    Write-Output "  GET_FAIL: $($_.Exception.Message)"
}

Write-Output "=== Approve via UpdateApprovalState ==="
try {
    $in = $inst.GetMethodParameters("UpdateApprovalState")
    $in["ApprovalState"] = "1"
    $in["Approver"] = "range\svc_sccm"
    $in["Comment"] = "CADRE WT039 approve"
    $r = $inst.InvokeMethod("UpdateApprovalState", $in, $null)
    Write-Output "  APPROVE_RETURN=$($r)"
    $inst.Get()
    Write-Output ("  Approval after={0}" -f $inst["ApprovalState"])
} catch {
    Write-Output "  APPROVE_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "  DETAILS: $($_.ErrorDetails.Message)" }
}

Write-Output "=== Existing SMS_ScriptsExecutionTask (schema) ==="
$tasks = Get-WmiObject -ComputerName mbr02.range.local -Credential (New-Object System.Management.Automation.PSCredential('range\svc_sccm',(ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))) -Namespace "root\SMS\site_CAD" -Class SMS_ScriptsExecutionTask -ErrorAction SilentlyContinue
Write-Output "  EXISTING_TASKS=$($tasks.Count)"
foreach ($t in $tasks) {
    Write-Output ("    Task: {0} | Col={1} | Script={2} | Feature={3} | State={4}" -f $t.TaskID, $t.CollectionId, $t.ScriptGuid, $t.Feature, $t.OverallScriptExecutionState)
}
Write-Output "DONE"
