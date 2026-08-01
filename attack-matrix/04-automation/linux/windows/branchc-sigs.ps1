$ErrorActionPreference = "SilentlyContinue"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

function Get-Sig($className, $methodName) {
    $c = New-Object System.Management.ManagementClass($scope, $className, $null)
    $m = $c.Methods[$methodName]
    if (-not $m) { Write-Output "  NO METHOD $methodName on $className"; return }
    Write-Output ("  {0}.{1}({2})" -f $className, $methodName, (($m.InParameters.Properties | ForEach-Object { "$($_.Name):$($_.Type)" }) -join ", "))
}

Write-Output "=== SMS_Scripts.CreateScripts ==="
Get-Sig "SMS_Scripts" "CreateScripts"
Write-Output "=== SMS_Scripts.UpdateApprovalState ==="
Get-Sig "SMS_Scripts" "UpdateApprovalState"
Write-Output "=== SMS_ScriptsExecutionTask ==="
$c = New-Object System.Management.ManagementClass($scope, "SMS_ScriptsExecutionTask", $null)
Write-Output ("  methods: {0}" -f (($c.Methods | ForEach-Object { $_.Name }) -join ", "))
Write-Output ("  props: {0}" -f (($c.Properties | ForEach-Object { $_.Name }) -join ", "))
Write-Output "=== SMS_Collection.CreateCCR ==="
Get-Sig "SMS_Collection" "CreateCCR"
Write-Output "=== SMS_Collection.GenerateCCRByName ==="
Get-Sig "SMS_Collection" "GenerateCCRByName"
Write-Output "=== SMS_ClientOperation.InitiateClientOperationEx ==="
Get-Sig "SMS_ClientOperation" "InitiateClientOperationEx"
Write-Output "=== SMS_ScriptsExecutionStatus ==="
$c2 = New-Object System.Management.ManagementClass($scope, "SMS_ScriptsExecutionStatus", $null)
Write-Output ("  props: {0}" -f (($c2.Properties | ForEach-Object { $_.Name }) -join ", "))
Write-Output "DONE"
