$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()
$guid = '200f5731-224e-4c6e-8acc-ef0193e47004'

Write-Output "=== SMS_Scripts instance methods ==="
$inst = New-Object System.Management.ManagementObject($scope, "SMS_Scripts.ScriptGuid='$guid'", $null)
$inst.Get()
Write-Output ("  Instance methods: " + (($inst.Methods | ForEach-Object { $_.Name }) -join ", "))

Write-Output "=== Try direct Put with ApprovalState=1 ==="
try {
    $inst["ApprovalState"] = [uint32]1
    $inst.Put()
    Write-Output "PUT_OK"
    $inst.Get()
    Write-Output "APPROVAL now=$($inst['ApprovalState'])"
} catch {
    Write-Output "PUT_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "  DETAILS: $($_.ErrorDetails.Message)" }
}

Write-Output "=== UpdateScriptsParameters signature ==="
$class = New-Object System.Management.ManagementClass($scope, "SMS_Scripts", $null)
$m = $class.Methods["UpdateScriptsParameters"]
if ($m) {
    Write-Output ("  params: " + (($m.InParameters.Properties | ForEach-Object { "$($_.Name):$($_.Type)" }) -join ", "))
}

Write-Output "=== Class-level method list (full) ==="
($class.Methods | ForEach-Object { $_.Name }) -join ", " | Out-String
Write-Output "DONE"
