$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

Write-Output "=== SMS_ScheduleMethods methods + sigs ==="
$sm = New-Object System.Management.ManagementClass($scope, "SMS_ScheduleMethods", $null)
foreach ($m in $sm.Methods) {
    Write-Output ("  METHOD {0}({1})" -f $m.Name, (($m.InParameters.Properties | ForEach-Object { "$($_.Name):$($_.Type)" }) -join ", "))
}
Write-Output "=== SMS_ScheduleToken properties ==="
$st = New-Object System.Management.ManagementClass($scope, "SMS_ScheduleToken", $null)
($st.Properties | ForEach-Object { $_.Name }) -join ", " | Out-String -Width 200
Write-Output "DONE"
