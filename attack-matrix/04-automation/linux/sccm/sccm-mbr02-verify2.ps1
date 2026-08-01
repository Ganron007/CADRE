# Verify mbr02 client after MP fix — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
$cl = 'C:\Program Files\SMS_CCM\Logs'
Write-Output '=== Assignment state ==='
$cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
Write-Output ("  CCM\AssignedSiteCode=" + $cp.AssignedSiteCode)
Write-Output ("  CCM\SMS_MP=" + $cp.SMS_MP)
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
$m = Get-ItemProperty $mc -ErrorAction SilentlyContinue
Write-Output ("  SMS\Mobile Client\AssignedSiteCode=" + $m.AssignedSiteCode)
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))
Write-Output ("  SMS_CCM_Logs=" + (Test-Path "$cl\LocationServices.log"))
Write-Output '=== LocationServices.log tail 20 ==='
if (Test-Path "$cl\LocationServices.log") { Get-Content "$cl\LocationServices.log" -Tail 20 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!><time="([^"]+)"') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } } } else { Write-Output '  (no LS log)' }
Write-Output '=== PolicyAgent.log tail 15 ==='
if (Test-Path "$cl\PolicyAgent.log") { Get-Content "$cl\PolicyAgent.log" -Tail 15 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } } else { Write-Output '  (no PA log)' }
Write-Output '=== ClientIDManagerStartup tail 10 ==='
if (Test-Path "$cl\ClientIDManagerStartup.log") { Get-Content "$cl\ClientIDManagerStartup.log" -Tail 10 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } }
Write-Output 'MBR02_VERIFY2_DONE'
