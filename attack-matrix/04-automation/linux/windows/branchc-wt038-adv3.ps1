$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

Write-Output "=== Build SMS_ScheduleToken ==="
$tokenClass = New-Object System.Management.ManagementClass($scope, "SMS_ScheduleToken", $null)
$token = $tokenClass.CreateInstance()
$token["StartTime"] = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).ToUniversalTime())
$token["DayDuration"] = [uint32]0
$token["HourDuration"] = [uint32]0
$token["MinuteDuration"] = [uint32]10
$token["IsGMT"] = $false
Write-Output "  TOKEN built: $($token['StartTime']) + $($token['MinuteDuration'])min"

Write-Output "=== Create SMS_Advertisement with token ==="
$advClass = New-Object System.Management.ManagementClass($scope, "SMS_Advertisement", $null)
$adv = $advClass.CreateInstance()
$adv["AdvertisementName"] = "CADRE-WT039-Deploy"
$adv["PackageID"] = "CAD00007"
$adv["ProgramName"] = "CADRE-WT039-Run"
$adv["CollectionID"] = "SMS00001"
$adv["Comment"] = "WT039"
$adv["OfferType"] = [uint32]1
$adv["DeviceFlags"] = [uint32]0
$adv["PresentTimeEnabled"] = $true
$adv["PresentTime"] = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).ToUniversalTime())
$adv["AssignedScheduleEnabled"] = $true
$adv["AssignedSchedule"] = [System.Management.ManagementBaseObject[]]@($token)
try {
    $adv.Put()
    $adv.Get()
    Write-Output "ADV_OK AdvertisementID=$($adv['AdvertisementID'])"
} catch {
    Write-Output "ADV_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "  DETAILS: $($_.ErrorDetails.Message)" }
}
Write-Output "DONE"
