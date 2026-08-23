[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$c = "C:\Tools\cadre-attack\Certify.exe"
if (-not (Test-Path $c)) { throw "Certify.exe not found" }
& $c find /vulnerable /domain:"cadre.local" /dc:"dc01.cadre.local"
Write-Output "T050_OK: ESC1 enumeration complete"
