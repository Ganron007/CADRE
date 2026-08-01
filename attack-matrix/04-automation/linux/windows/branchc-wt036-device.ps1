$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

Write-Output "=== Create SMS_R_System device: provisioning ==="
$rsClass = New-Object System.Management.ManagementClass($scope, "SMS_R_System", $null)
$r = $rsClass.CreateInstance()
$r["Name"] = "provisioning"
try {
    $r.Put()
    $r.Get()
    Write-Output "  DEVICE_OK ResourceID=$($r['ResourceId'])"
} catch {
    Write-Output "  DEVICE_PUT_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "    DETAILS: $($_.ErrorDetails.Message)" }
    Write-Output "=== retry with agent fields ==="
    try {
        $r2 = $rsClass.CreateInstance()
        $r2["Name"] = "provisioning"
        $r2["AgentName"] = "SMS Discovery"
        $r2["AgentSite"] = "CAD"
        $r2["NetbiosName"] = "provisioning"
        $r2.Put()
        $r2.Get()
        Write-Output "  DEVICE2_OK ResourceID=$($r2['ResourceId'])"
    } catch {
        Write-Output "  DEVICE2_FAIL: $($_.Exception.Message)"
        if ($_.ErrorDetails) { Write-Output "    DETAILS2: $($_.ErrorDetails.Message)" }
    }
}
Write-Output "DONE"
