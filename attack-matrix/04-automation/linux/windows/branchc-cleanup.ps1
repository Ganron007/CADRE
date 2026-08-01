$ErrorActionPreference = "Stop"
$opts = New-Object System.Management.ConnectionOptions
$opts.Username = 'range\svc_sccm'
$opts.Password = 's3rv1c3_SCCM!'
$opts.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope("\\mbr02.range.local\root\SMS\site_CAD", $opts)
$scope.Connect()

Write-Output "=== Remove test scripts (CADRE-WT039*) ==="
$sec = New-Object System.Management.Automation.PSCredential('range\svc_sccm',(ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))
$scripts = Get-WmiObject -ComputerName mbr02.range.local -Credential $sec -Namespace "root\SMS\site_CAD" -Class SMS_Scripts -ErrorAction SilentlyContinue | Where-Object { $_.ScriptName -like "CADRE-WT039*" }
foreach ($s in $scripts) {
    Write-Output "  Deleting script: $($s.ScriptName) ($($s.ScriptGuid))"
    $inst = New-Object System.Management.ManagementObject($scope, "SMS_Scripts.ScriptGuid='$($s.ScriptGuid)'", $null)
    try { $inst.Delete() ; Write-Output "    DELETED" } catch { Write-Output "    DELETE_FAIL: $($_.Exception.Message)" }
}

Write-Output "=== Remove test package+program (CAD00007) ==="
try {
    $pkg = New-Object System.Management.ManagementObject($scope, "SMS_Package.PackageID='CAD00007'", $null)
    $pkg.Delete()
    Write-Output "  Package CAD00007 DELETED"
} catch {
    Write-Output "  PKG_DELETE_FAIL: $($_.Exception.Message)"
}

Write-Output "=== Verify cleanup ==="
$left = Get-WmiObject -ComputerName mbr02.range.local -Credential $sec -Namespace "root\SMS\site_CAD" -Class SMS_Scripts -ErrorAction SilentlyContinue | Where-Object { $_.ScriptName -like "CADRE-WT039*" }
Write-Output "  Remaining scripts: $($left.Count)"
$pkgs = Get-WmiObject -ComputerName mbr02.range.local -Credential $sec -Namespace "root\SMS\site_CAD" -Class SMS_Package -ErrorAction SilentlyContinue | Where-Object { $_.PackageID -eq "CAD00007" }
Write-Output "  Remaining packages: $($pkgs.Count)"
Write-Output "DONE"
