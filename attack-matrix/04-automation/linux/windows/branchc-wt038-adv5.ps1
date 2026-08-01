$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()
$advClass = New-Object System.Management.ManagementClass($scope, "SMS_Advertisement", $null)

$tokenClass = New-Object System.Management.ManagementClass($scope, "SMS_ScheduleToken", $null)
$token = $tokenClass.CreateInstance()
$token["StartTime"] = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).ToUniversalTime())
$token["DayDuration"] = [uint32]0
$token["HourDuration"] = [uint32]0
$token["MinuteDuration"] = [uint32]10
$token["IsGMT"] = $false

Write-Output "=== Variant A: DeviceFlags=1, TimeFlags=1, PresentTime ==="
try {
    $a = $advClass.CreateInstance()
    $a["AdvertisementName"] = "CADRE-WT039-Deploy-C"
    $a["PackageID"] = "CAD00007"
    $a["ProgramName"] = "CADRE-WT039-Run"
    $a["CollectionID"] = "SMS00001"
    $a["OfferType"] = [uint32]0
    $a["DeviceFlags"] = [uint32]1
    $a["PresentTimeEnabled"] = $true
    $a["PresentTime"] = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).ToUniversalTime())
    $a["TimeFlags"] = [uint32]1
    $a.Put()
    $a.Get()
    Write-Output "  OK ID=$($a['AdvertisementID'])"
} catch {
    Write-Output "  FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "    DETAILS: $($_.ErrorDetails.Message)" }
}

Write-Output "=== Variant B: DeviceFlags=1, TimeFlags=3, PresentTime+token ==="
try {
    $a2 = $advClass.CreateInstance()
    $a2["AdvertisementName"] = "CADRE-WT039-Deploy-D"
    $a2["PackageID"] = "CAD00007"
    $a2["ProgramName"] = "CADRE-WT039-Run"
    $a2["CollectionID"] = "SMS00001"
    $a2["OfferType"] = [uint32]1
    $a2["DeviceFlags"] = [uint32]1
    $a2["PresentTimeEnabled"] = $true
    $a2["PresentTime"] = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).ToUniversalTime())
    $a2["AssignedScheduleEnabled"] = $true
    $a2["AssignedSchedule"] = [System.Management.ManagementBaseObject[]]@($token)
    $a2["TimeFlags"] = [uint32]3
    $a2.Put()
    $a2.Get()
    Write-Output "  OK ID=$($a2['AdvertisementID'])"
} catch {
    Write-Output "  FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "    DETAILS: $($_.ErrorDetails.Message)" }
}
Write-Output "DONE"
