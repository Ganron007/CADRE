$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

Write-Output "=== Create SMS_Advertisement (fixed) ==="
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
$adv["AssignedSchedule"] = [string[]]@("<RecurrenceInterval Interval=""1"" IsGMT=""false"" />")
try {
    $adv.Put()
    $adv.Get()
    Write-Output "ADV_OK AdvertisementID=$($adv['AdvertisementID'])"
    Write-Output "  Name=$($adv['AdvertisementName']) | Pkg=$($adv['PackageID']) | Prog=$($adv['ProgramName']) | Col=$($adv['CollectionID'])"
} catch {
    Write-Output "ADV_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "  DETAILS: $($_.ErrorDetails.Message)" }
}
Write-Output "DONE"
