$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

$advClass = New-Object System.Management.ManagementClass($scope, "SMS_Advertisement", $null)

Write-Output "=== Variant 1: OfferType=0 (Available), PresentTime, no AssignedSchedule ==="
try {
    $a = $advClass.CreateInstance()
    $a["AdvertisementName"] = "CADRE-WT039-Deploy-A"
    $a["PackageID"] = "CAD00007"
    $a["ProgramName"] = "CADRE-WT039-Run"
    $a["CollectionID"] = "SMS00001"
    $a["Comment"] = "WT039"
    $a["OfferType"] = [uint32]0
    $a["DeviceFlags"] = [uint32]0
    $a["PresentTimeEnabled"] = $true
    $a["PresentTime"] = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).ToUniversalTime())
    $a.Put()
    $a.Get()
    Write-Output "  ADV1_OK ID=$($a['AdvertisementID'])"
} catch {
    Write-Output "  ADV1_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "    DETAILS: $($_.ErrorDetails.Message)" }
}

Write-Output "=== Variant 2: minimal (OfferType=0, no times) ==="
try {
    $a2 = $advClass.CreateInstance()
    $a2["AdvertisementName"] = "CADRE-WT039-Deploy-B"
    $a2["PackageID"] = "CAD00007"
    $a2["ProgramName"] = "CADRE-WT039-Run"
    $a2["CollectionID"] = "SMS00001"
    $a2["OfferType"] = [uint32]0
    $a2["DeviceFlags"] = [uint32]0
    $a2.Put()
    $a2.Get()
    Write-Output "  ADV2_OK ID=$($a2['AdvertisementID'])"
} catch {
    Write-Output "  ADV2_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "    DETAILS: $($_.ErrorDetails.Message)" }
}
Write-Output "DONE"
