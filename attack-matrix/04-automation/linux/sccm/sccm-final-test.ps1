# Final mbr02 attempt: set assignment on FRESH client + restart + watch LS log — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
$cl = 'C:\Program Files\SMS_CCM\Logs'

Write-Output '=== Set assignment values ==='
New-Item -Path $c -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $mc -Force -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -Path $c -Name AssignedSiteCode -Value 'CAD' -PropertyType String -Force | Out-Null
New-ItemProperty -Path $c -Name SMS_MP -Value 'mbr02.range.local' -PropertyType String -Force | Out-Null
New-ItemProperty -Path $mc -Name AssignedSiteCode -Value 'CAD' -PropertyType String -Force | Out-Null
Write-Output '  written'

Write-Output '=== Clear old LS log for clean read ==='
if (Test-Path "$cl\LocationServices.log") { Move-Item "$cl\LocationServices.log" "$cl\LocationServices.old.log" -Force -ErrorAction SilentlyContinue }

Write-Output '=== Restart CcmExec ==='
Restart-Service CcmExec -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 60

Write-Output '=== After 60s ==='
$cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
Write-Output ("  CCM\AssignedSiteCode=" + $cp.AssignedSiteCode)
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))
Write-Output ("  LS log exists=" + (Test-Path "$cl\LocationServices.log"))
Write-Output '=== LocationServices.log (fresh) tail 30 ==='
if (Test-Path "$cl\LocationServices.log") {
  Get-Content "$cl\LocationServices.log" -Tail 30 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!><time="([^"]+)"') { Write-Output ("[" + $matches[2] + "] " + $matches[1]) } else { Write-Output $_ } }
} else { Write-Output '  (no LS log yet)' }

Write-Output '=== PolicyAgent.log tail 15 ==='
if (Test-Path "$cl\PolicyAgent.log") { Get-Content "$cl\PolicyAgent.log" -Tail 15 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } } else { Write-Output '  (no PA log yet)' }
Write-Output 'FINALTEST_DONE'
