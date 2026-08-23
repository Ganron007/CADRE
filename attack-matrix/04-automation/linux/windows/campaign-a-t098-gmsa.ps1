[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"
$g = Get-ADServiceAccount -Filter * -Server dc01.cadre.local -Properties msDS-ManagedPasswordId, SID -ErrorAction SilentlyContinue
if ($g) { $g | ForEach-Object { Write-Output ("GMSA|" + $_.Name + "|" + $_.SID) } } else { Write-Output "GMSA_ENUM_ALT" }
Write-Output "T098_PREREQ_DONE"
