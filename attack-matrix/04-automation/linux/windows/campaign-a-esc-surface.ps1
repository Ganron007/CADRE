[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Marker,
    [Parameter(Mandatory = $true)][string]$Pattern,
    [switch]$AllTemplates
)
$ErrorActionPreference = "Continue"
$c = "C:\Tools\cadre-attack\Certify.exe"
if (-not (Test-Path -LiteralPath $c -ErrorAction SilentlyContinue)) {
    Write-Output "ESC_CERTIFY_MISSING"
    exit 1
}
Write-Output ("CERTIFY=" + $c)
if ($AllTemplates) {
    $out = & $c find /domain:cadre.local /dc:dc01.cadre.local 2>&1 | Out-String
} else {
    $out = & $c find /vulnerable /domain:cadre.local /dc:dc01.cadre.local 2>&1 | Out-String
}
Write-Output $out
if ($out -notmatch $Pattern) {
    Write-Output ($Marker + "_FAIL: Certify output missing /" + $Pattern + "/")
    exit 1
}
Write-Output ($Marker + "_OK")
