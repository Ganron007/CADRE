# Verify client assignment on ws01 — analyst_t1
$ErrorActionPreference = 'Continue'
Write-Output '=== ASSIGNMENT CHECK ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
if (Test-Path $c) {
  $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
  Write-Output ("  AssignedSiteCode=" + $cp.AssignedSiteCode)
  Write-Output ("  SMS_MP=" + $cp.SMS_MP)
} else { Write-Output '  CCM reg absent' }
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
if (Test-Path $mc) { $m = Get-ItemProperty $mc -ErrorAction SilentlyContinue; Write-Output ("  SMS\Mobile Client\AssignedSiteCode=" + $m.AssignedSiteCode) }
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec=" + $_.Status) }
Write-Output '=== CCM LOGS ==='
$logs = 'C:\Windows\CCM\Logs'
if (Test-Path $logs) {
  Get-ChildItem $logs -Filter '*.log' | Select-Object -First 15 | ForEach-Object { Write-Output ("  " + $_.Name) }
  $pa = "$logs\PolicyAgent.log"
  if (Test-Path $pa) { Write-Output '  --- PolicyAgent.log tail ---'; Get-Content $pa -Tail 12 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } } }
  $cs = "$logs\ClientIDManagerStartup.log"
  if (Test-Path $cs) { Write-Output '  --- ClientIDManagerStartup.log tail ---'; Get-Content $cs -Tail 12 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } } }
} else { Write-Output '  NO C:\Windows\CCM\Logs' }
Write-Output 'WS01_VERIFY_DONE'
