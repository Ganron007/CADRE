# Check site AD publishing logs + component state — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$siteLogs = 'C:\Program Files\Microsoft Configuration Manager\Logs'

Write-Output '=== AD-related logs in site logs ==='
Get-ChildItem $siteLogs -Filter '*.log' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'AD|Forest|Update' } | ForEach-Object { Write-Output ("  " + $_.Name + " | " + $_.LastWriteTime + " | " + $_.Length) }

Write-Output '=== ADUPDATE.log tail (if exists) ==='
$ad = "$siteLogs\ADUPDATE.log"
if (Test-Path $ad) { Get-Content $ad -Tail 40 | ForEach-Object { Write-Output $_ } } else { Write-Output '  (no ADUPDATE.log)' }

Write-Output '=== ADManager.log tail (if exists) ==='
$adm = "$siteLogs\ADManager.log"
if (Test-Path $adm) { Get-Content $adm -Tail 40 | ForEach-Object { Write-Output $_ } } else { Write-Output '  (no ADManager.log)' }

Write-Output '=== hman / site control processing logs (recent) ==='
foreach ($f in @("$siteLogs\hman.log","$siteLogs\smsdbmon.log")) {
  if (Test-Path $f) { Write-Output ("  --- " + $f + " tail ---"); Get-Content $f -Tail 15 | ForEach-Object { Write-Output $_ } }
}
Write-Output 'ADLOG_DONE'
