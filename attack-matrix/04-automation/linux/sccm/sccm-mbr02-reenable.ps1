# Re-enable + assign the mbr02 client (MP is now fixed) — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
$cl = 'C:\Program Files\SMS_CCM\Logs'

Write-Output '=== 1. Re-enable CcmExec service ==='
sc.exe config CcmExec start= demand | Out-Null
Write-Output '  CcmExec set to demand start'

Write-Output '=== 2. Ensure site assignment values ==='
New-Item -Path $c -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $mc -Force -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -Path $c -Name AssignedSiteCode -Value 'CAD' -PropertyType String -Force | Out-Null
New-ItemProperty -Path $c -Name SMS_MP -Value 'mbr02.range.local' -PropertyType String -Force | Out-Null
New-ItemProperty -Path $mc -Name AssignedSiteCode -Value 'CAD' -PropertyType String -Force | Out-Null
$m = Get-ItemProperty $mc -ErrorAction SilentlyContinue
Write-Output ("  SMS\Mobile Client\AssignedSiteCode=" + $m.AssignedSiteCode)

Write-Output '=== 3. Clear stale client logs for clean read ==='
if (Test-Path "$cl\LocationServices.log") { Move-Item "$cl\LocationServices.log" "$cl\LocationServices.old2.log" -Force -ErrorAction SilentlyContinue }
if (Test-Path "$cl\PolicyAgent.log") { Move-Item "$cl\PolicyAgent.log" "$cl\PolicyAgent.old2.log" -Force -ErrorAction SilentlyContinue }

Write-Output '=== 4. Start CcmExec ==='
Start-Service CcmExec -ErrorAction SilentlyContinue
Start-Sleep -Seconds 10
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec=" + $_.Status + " start=" + $_.StartType) }
Write-Output 'MBR02_REENABLE_DONE'
