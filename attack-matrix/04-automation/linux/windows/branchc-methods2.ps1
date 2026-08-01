$ErrorActionPreference = "SilentlyContinue"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()
Write-Output "SCOPE_CONNECTED=$($scope.IsConnected)"

function Get-Methods($className) {
    $c = New-Object System.Management.ManagementClass($scope, $className, $null)
    $names = foreach ($m in $c.Methods) { $m.Name }
    Write-Output ("  {0} methods: {1}" -f $className, ($names -join ", "))
}

Write-Output "=== SMS_Scripts ==="
Get-Methods "SMS_Scripts"
Write-Output "=== SMS_Application ==="
Get-Methods "SMS_Application"
Write-Output "=== SMS_Collection ==="
Get-Methods "SMS_Collection"
Write-Output "=== SMS_ApplicationAssignment ==="
Get-Methods "SMS_ApplicationAssignment"
Write-Output "=== SMS_DeploymentType ==="
Get-Methods "SMS_DeploymentType"
Write-Output "=== SMS_ClientOperation / SMS_TaskSequence ==="
Get-Methods "SMS_ClientOperation"
Write-Output "DONE"
