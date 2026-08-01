$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

Write-Output "=== GenerateCCRByName (class-level) ==="
$class = New-Object System.Management.ManagementClass($scope, "SMS_Collection", $null)
try {
    $in = $class.Methods["GenerateCCRByName"].InParameters
    $in["Forced"] = $true
    $in["Name"] = "provisioning"
    $in["PushSiteCode"] = "CAD"
    $ret = $class.InvokeMethod("GenerateCCRByName", $in, $null)
    Write-Output "  RETURN=$($ret.ReturnValue)"
    foreach ($p in $ret.Properties) { Write-Output ("  OUT {0} = {1}" -f $p.Name, $p.Value) }
} catch {
    Write-Output "  CLASS_FAIL: $($_.Exception.Message)"
    Write-Output "=== Try on All Systems collection instance ==="
    try {
        $inst = New-Object System.Management.ManagementObject($scope, "SMS_Collection.CollectionID='SMS00001'", $null)
        $inst.Get()
        $ip = $inst.GetMethodParameters("GenerateCCRByName")
        $ip["Forced"] = $true
        $ip["Name"] = "provisioning"
        $ip["PushSiteCode"] = "CAD"
        $r2 = $inst.InvokeMethod("GenerateCCRByName", $ip, $null)
        Write-Output "  INSTANCE RETURN=$r2"
    } catch {
        Write-Output "  INSTANCE_FAIL: $($_.Exception.Message)"
        if ($_.ErrorDetails) { Write-Output "    DETAILS: $($_.ErrorDetails.Message)" }
    }
}
Write-Output "DONE"
