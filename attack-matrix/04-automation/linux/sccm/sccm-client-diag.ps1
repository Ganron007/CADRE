# SCCM client/DP diagnosis on mbr02 (CONFIG, vagrant via WinRM) — no regex, raw output
$ErrorActionPreference = 'Continue'
Write-Output '=== Kill ccmsetup + verify dead ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 3
$still = tasklist | findstr /i ccmsetup
if ($still) { Write-Output ('STILL_RUNNING: ' + $still) } else { Write-Output 'CCMSETUP_DEAD' }
Write-Output '=== Boundaries ==='
try {
  Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_Boundary -ErrorAction Stop | ForEach-Object { Write-Output ('BOUNDARY: ' + $_.DisplayName + ' | type=' + $_.BoundaryType + ' | ' + $_.Value) }
} catch { Write-Output ('BOUNDARY_ERR: ' + $_.Exception.Message) }
Write-Output '=== Boundary Groups ==='
try {
  Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_BoundaryGroup -ErrorAction Stop | ForEach-Object { Write-Output ('BG: ' + $_.Name + ' (id=' + $_.GroupID + ')') }
} catch { Write-Output ('BG_ERR: ' + $_.Exception.Message) }
Write-Output '=== Distribution Points ==='
try {
  Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_DistributionPoint -ErrorAction Stop | ForEach-Object { Write-Output ('DP: ' + $_.NALPath + ' | ' + $_.RoleName) }
} catch { Write-Output ('DP_ERR: ' + $_.Exception.Message) }
Write-Output '=== Launch ccmsetup /source ==='
$p = Start-Process -FilePath 'C:\Windows\CCMSetup\ccmsetup.exe' -ArgumentList '/source:"C:\Program Files\Microsoft Configuration Manager\Client" /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -PassThru -WindowStyle Hidden
Write-Output ('PID=' + $p.Id)
Start-Sleep -Seconds 45
$alive = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
Write-Output ('ALIVE_45S=' + [bool]$alive)
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Write-Output '--- raw tail 12 ---'
  Get-Content $log -Tail 12
} else { Write-Output 'NO_LOG' }
Write-Output 'DIAG_DONE'
