# Verify client assignment on mbr02 — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Write-Output '=== ASSIGNMENT CHECK ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
if (Test-Path $c) {
  $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
  Write-Output ("  AssignedSiteCode=" + $cp.AssignedSiteCode)
  Write-Output ("  SMS_MP=" + $cp.SMS_MP)
} else { Write-Output '  CCM reg GONE' }
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))
Write-Output ("  SMS_CCM_DIR=" + (Test-Path 'C:\Program Files\SMS_CCM'))
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec=" + $_.Status) }
Write-Output '=== CCM LOGS ==='
$logs = 'C:\Windows\CCM\Logs'
if (Test-Path $logs) {
  Get-ChildItem $logs -Filter '*.log' -ErrorAction SilentlyContinue | Select-Object -First 20 | ForEach-Object { Write-Output ('  ' + $_.Name) }
  $pa = "$logs\PolicyAgent.log"
  if (Test-Path $pa) { Write-Output '  --- PolicyAgent.log tail ---'; Get-Content $pa -Tail 15 | ForEach-Object { Write-Output $_ } }
  $cs = "$logs\ClientIDManagerStartup.log"
  if (Test-Path $cs) { Write-Output '  --- ClientIDManagerStartup.log tail ---'; Get-Content $cs -Tail 15 | ForEach-Object { Write-Output $_ } }
} else { Write-Output '  NO C:\Windows\CCM\Logs' }
Write-Output '=== ccmsetup.log tail ==='
$cl = 'C:\Windows\ccmsetup\Logs\ccmsetup.log'
if (Test-Path $cl) { Get-Content $cl -Tail 25 | ForEach-Object { Write-Output $_ } } else { Write-Output '  no ccmsetup.log' }
Write-Output 'VERIFY_DONE'
