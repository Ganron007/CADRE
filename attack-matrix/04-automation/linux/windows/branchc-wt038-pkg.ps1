$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

$proof = 'cmd /c "echo WT039_PROOF %USERNAME% %COMPUTERNAME% %DATE% %TIME% > C:\Shares\vault\wt039-proof.txt & whoami >> C:\Shares\vault\wt039-proof.txt"'

Write-Output "=== Create SMS_Package ==="
$pkgClass = New-Object System.Management.ManagementClass($scope, "SMS_Package", $null)
$pkg = $pkgClass.CreateInstance()
$pkg["Name"] = "CADRE-WT039-Payload"
$pkg["Manufacturer"] = "CADRE"
$pkg["Version"] = "1.0"
$pkg["Language"] = "English"
$pkg["PkgSourceFlag"] = [uint32]0
$pkg["PkgSourcePath"] = ""
try {
    $pkg.Put()
    $pkg.Get()
    Write-Output "PKG_OK PackageID=$($pkg['PackageID'])"
} catch {
    Write-Output "PKG_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "  DETAILS: $($_.ErrorDetails.Message)" }
    Write-Output "=== retry minimal ==="
    try {
        $pkg2 = $pkgClass.CreateInstance()
        $pkg2["Name"] = "CADRE-WT039-Payload"
        $pkg2.Put()
        $pkg2.Get()
        Write-Output "PKG2_OK PackageID=$($pkg2['PackageID'])"
    } catch {
        Write-Output "PKG2_FAIL: $($_.Exception.Message)"
        if ($_.ErrorDetails) { Write-Output "  DETAILS2: $($_.ErrorDetails.Message)" }
    }
}
Write-Output "DONE"
