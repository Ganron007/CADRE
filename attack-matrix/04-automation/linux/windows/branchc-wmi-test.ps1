$ErrorActionPreference = "Stop"
$secpass = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', $secpass)
try {
    Write-Output "=== WMI connect root\SMS\site_CAD as svc_sccm ==="
    $admins = Get-WmiObject -ComputerName mbr02.range.local -Credential $cred -Namespace "root\SMS\site_CAD" -Class SMS_Admin -ErrorAction Stop
    $admins | Select-Object LogonName, AdminSID, IsBuiltIn | Format-Table -AutoSize | Out-String -Width 200
    Write-Output "ADMIN_COUNT=$($admins.Count)"
} catch {
    Write-Output "WMI_FAIL: $($_.Exception.Message)"
    Write-Output "INNER: $($_.Exception.InnerException.Message)"
}
Write-Output "DONE"
