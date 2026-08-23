[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$pkg = Get-WmiObject -Namespace "root\ccm\clientsdk" -Class CCM_Application -ErrorAction SilentlyContinue
if ($pkg) {
    Write-Output "T038_OK: CCM_Application query succeeded"
    $pkg | Select-Object Name, Id, InstallState -First 5 | Format-Table -AutoSize
} else { Write-Output "T038_INFO: no CCM_Application objects" }
Write-Output "T038_OK: app deploy check complete"
