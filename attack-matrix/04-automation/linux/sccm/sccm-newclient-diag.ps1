# Post-fresh-install diagnostics on the NEW client — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$cl = 'C:\Program Files\SMS_CCM\Logs'

Write-Output '=== Registry site code values ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
if (Test-Path $c) { $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue; Write-Output ("  CCM\AssignedSiteCode=" + $cp.AssignedSiteCode + " SMS_MP=" + $cp.SMS_MP) } else { Write-Output '  CCM reg absent' }
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
if (Test-Path $mc) { $mp = Get-ItemProperty $mc -ErrorAction SilentlyContinue; Write-Output ("  SMS\Mobile Client\AssignedSiteCode=" + $mp.AssignedSiteCode) } else { Write-Output '  SMS\Mobile Client absent' }

Write-Output '=== ccmsetup.log head (18:24 run) - command line + MSI props ==='
Get-Content 'C:\Windows\ccmsetup\Logs\ccmsetup.log' -TotalCount 40 | Where-Object { $_ -match 'command line|MSI PROPERTIES|Invalid argument|SmsSetClientConfig|SMSSITECODE|SMSMP|RESETKEY|Detected client' } | ForEach-Object {
  if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) }
}

Write-Output '=== NEW LocationServices.log tail 25 ==='
$ls = "$cl\LocationServices.log"
if (Test-Path $ls) { Get-Content $ls -Tail 25 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!><time="([^"]+)"') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } } } else { Write-Output '  (no LS log yet)' }

Write-Output '=== NEW PolicyAgent.log tail 20 ==='
$pa = "$cl\PolicyAgent.log"
if (Test-Path $pa) { Get-Content $pa -Tail 20 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!><time="([^"]+)"') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } } } else { Write-Output '  (no PA log yet)' }

Write-Output '=== Client logs present ==='
Get-ChildItem $cl -Filter '*.log' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 12 | ForEach-Object { Write-Output ("  " + $_.Name + " | " + $_.LastWriteTime) }
Write-Output 'NEWCLIENT_DONE'
