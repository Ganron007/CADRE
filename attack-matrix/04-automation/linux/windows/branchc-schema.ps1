$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

foreach ($cn in @("SMS_Program", "SMS_Advertisement", "SMS_Package")) {
    Write-Output "=== $cn properties ==="
    try {
        $c = New-Object System.Management.ManagementClass($scope, $cn, $null)
        ($c.Properties | ForEach-Object { $_.Name }) -join ", " | Out-String -Width 250
    } catch {
        Write-Output "  CLASS_ERR: $($_.Exception.Message)"
    }
}
Write-Output "DONE"
