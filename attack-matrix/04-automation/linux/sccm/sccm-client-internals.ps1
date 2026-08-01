# Client internals on mbr02 — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== CcmExec service PathName ==='
Get-CimInstance Win32_Service -Filter "Name='CcmExec'" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  PathName=" + $_.PathName + " State=" + $_.State + " StartName=" + $_.StartName) }

Write-Output '=== All CCM-related services ==='
Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'CCM|SMS|RemoteControl' -or $_.PathName -match 'ccm|SMS_CCM' } | ForEach-Object { Write-Output ("  " + $_.Name + " | " + $_.State + " | " + $_.PathName) }

Write-Output '=== CcmExec process ==='
Get-Process CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  PID=" + $_.Id + " Path=" + $_.Path) }

Write-Output '=== ccmcache contents ==='
if (Test-Path 'C:\Windows\ccmcache') { Get-ChildItem 'C:\Windows\ccmcache' -ErrorAction SilentlyContinue | Select-Object -First 10 | ForEach-Object { Write-Output ("  " + $_.Name) } } else { Write-Output '  none' }

Write-Output '=== CCMINSTALLDIR registry ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
$cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
Write-Output ("  CCMINSTALLDIR=" + $cp.CCMINSTALLDIR)
Write-Output ("  CCMInstallDir=" + $cp.CCMInstallDir)

Write-Output '=== SMS_Client class methods ==='
try {
  $mc = [wmiclass]"root\ccm:SMS_Client"
  $mc.Methods | ForEach-Object { Write-Output ("  METHOD: " + $_.Name) }
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== Trigger machine policy cycle (standard schedule ID) ==='
try {
  $result = ([wmiclass]"root\ccm:SMS_Client").TriggerSchedule("{00000000-0000-0000-0000-000000000021}")
  Write-Output ("  TriggerSchedule result: " + $result.ReturnValue)
} catch { Write-Output ("  TriggerSchedule ERROR: " + $_.Exception.Message) }

Write-Output '=== Trigger location services / policy agent (schedule 023) ==='
try {
  $r2 = ([wmiclass]"root\ccm:SMS_Client").TriggerSchedule("{00000000-0000-0000-0000-000000000023}")
  Write-Output ("  TriggerSchedule 023 result: " + $r2.ReturnValue)
} catch { Write-Output ("  Trigger 023 ERROR: " + $_.Exception.Message) }

Write-Output '=== CCM scheduled tasks ==='
Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'CCM|ConfigMgr|SMS' } | ForEach-Object { Write-Output ("  " + $_.TaskName + " | " + $_.State) }
Write-Output 'INTERNALS_DONE'
