$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()
$guid = '200f5731-224e-4c6e-8acc-ef0193e47004'

Write-Output "=== Create SMS_ScriptsExecutionTask ==="
$taskClass = New-Object System.Management.ManagementClass($scope, "SMS_ScriptsExecutionTask", $null)
$task = $taskClass.CreateInstance()
$task["CollectionId"] = "SMS00001"
$task["ScriptGuid"] = $guid
$task["Timeout"] = [uint32]120
try {
    $task.Put()
    Write-Output "TASK_PUT_OK"
    $task.Get()
    Write-Output ("  TaskID={0} | Feature={1} | Col={2} | State={3}" -f $task["TaskID"], $task["Feature"], $task["CollectionId"], $task["OverallScriptExecutionState"])
} catch {
    Write-Output "TASK_PUT_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "  DETAILS: $($_.ErrorDetails.Message)" }
    # Try without Timeout
    Write-Output "=== Retry without Timeout ==="
    try {
        $task2 = $taskClass.CreateInstance()
        $task2["CollectionId"] = "SMS00001"
        $task2["ScriptGuid"] = $guid
        $task2.Put()
        Write-Output "TASK2_PUT_OK"
        $task2.Get()
        Write-Output ("  TaskID={0} | Feature={1} | State={2}" -f $task2["TaskID"], $task2["Feature"], $task2["OverallScriptExecutionState"])
    } catch {
        Write-Output "TASK2_FAIL: $($_.Exception.Message)"
        if ($_.ErrorDetails) { Write-Output "  DETAILS2: $($_.ErrorDetails.Message)" }
    }
}
Write-Output "DONE"
