[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$reg = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\CCMSetup" -ErrorAction SilentlyContinue
if ($reg) { Write-Output "T034_OK: SCCM client setup found"; Write-Output $reg } else { Write-Output "T034_INFO: SCCM client setup not found on ws01" }
Write-Output "T034_OK: SCCM site check complete"
