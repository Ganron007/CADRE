[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$pv = "C:\Tools\cadre-attack\PowerView.ps1"
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found" }
. $pv
Write-Output "=== GPOs ==="
Get-DomainGPO -Server "dc01.cadre.local" | Select-Object displayName, gpcFileSysPath | Format-Table -AutoSize
Write-Output "=== GPO Links ==="
Get-DomainGPO -Server "dc01.cadre.local" | Get-DomainObjectAcl -ResolveGUIDs | Select-Object ObjectDN, ActiveDirectoryRights, SecurityIdentifier | Format-Table -AutoSize
Write-Output "T023_OK: GPO enumeration complete"
