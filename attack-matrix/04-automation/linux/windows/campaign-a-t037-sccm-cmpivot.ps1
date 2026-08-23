[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$path = "C:\Windows\CCM\CcmExec.exe"
if (Test-Path $path) { Write-Output "T037_OK: SCCM client binary present" } else { Write-Output "T037_INFO: SCCM client not present" }
Write-Output "T037_OK: CMPivot check complete"
