[CmdletBinding()]
param()
$out = "C:\Tools\ADTools\T004-bh-out"
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out -Force | Out-Null }
$z = Get-ChildItem $out -Filter *.zip -ErrorAction SilentlyContinue | Select-Object -First 1
if ($z) { Write-Output ("T004_BH_OK: BloodHound zip found: " + $z.FullName) } else { Write-Output "T004_BH_FAIL: no SharpHound zip in $out" }
