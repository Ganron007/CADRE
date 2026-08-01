# Deep ws01 client verify — analyst_t1
$ErrorActionPreference = 'Continue'
Write-Output '=== Final assignment state ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
$cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
Write-Output ("  CCM\AssignedSiteCode=" + $cp.AssignedSiteCode)
Write-Output ("  CCM\SMS_MP=" + $cp.SMS_MP)
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
$m = Get-ItemProperty $mc -ErrorAction SilentlyContinue
Write-Output ("  SMS\Mobile Client\AssignedSiteCode=" + $m.AssignedSiteCode)
Write-Output ("  SMS\Mobile Client\SMSUniqueIdentifier=" + $m.SMSUniqueIdentifier)
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec=" + $_.Status) }
Write-Output '=== Client ID / registration ==='
$cs = 'C:\Windows\CCM\Logs\ClientIDManagerStartup.log'
if (Test-Path $cs) { Get-Content $cs -Tail 20 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } }
Write-Output '=== PolicyAgent activity ==='
$pa = 'C:\Windows\CCM\Logs\PolicyAgent.log'
if (Test-Path $pa) { Get-Content $pa -Tail 25 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } }
Write-Output '=== CcmMessaging (MP communication) tail ==='
$mm = 'C:\Windows\CCM\Logs\CcmMessaging.log'
if (Test-Path $mm) { Get-Content $mm -Tail 15 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } }
Write-Output 'WS01_DEEP_DONE'
