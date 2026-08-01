# PHASE 2: FRESH client install (true fresh - MSI product gone) — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== 0. Try cmd-level cleanup of residuals ==='
cmd /c "rd /s /q ""C:\Program Files\SMS_CCM""" 2>&1 | Out-Null
cmd /c 'reg delete "HKLM\SOFTWARE\Microsoft\CCM" /f' 2>&1 | Out-Null
Start-Sleep -Seconds 2
Write-Output ("  SMS_CCM=" + (Test-Path 'C:\Program Files\SMS_CCM'))
Write-Output ("  CCM_REG=" + (Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM'))

Write-Output '=== 1. Source check ==='
$src = 'C:\Windows\Temp\SMSSETUP\CLIENT'
Write-Output ("  SOURCE=" + (Test-Path "$src\ccmsetup.exe"))

Write-Output '=== 2. Fresh install (correct property syntax + RESETKEYINFORMATION) ==='
$cmd = "`"$src\ccmsetup.exe`" /source:$src SMSSITECODE=CAD SMSMP=mbr02.range.local RESETKEYINFORMATION=TRUE /NoCRLCheck"
Write-Output ("  CMDLINE: " + $cmd)
Set-Content -Path 'C:\Windows\Temp\cadre-client-fresh.cmd' -Value $cmd -Encoding ASCII
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','C:\Windows\Temp\cadre-client-fresh.cmd' -WindowStyle Hidden -PassThru
Write-Output ("  LAUNCH_PID=" + $p.Id)
Start-Sleep -Seconds 20

Write-Output '=== 3. State 20s after launch ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
if (Test-Path $c) { $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue; Write-Output ("  AssignedSiteCode=" + $cp.AssignedSiteCode) } else { Write-Output '  CCM reg absent yet' }
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec=" + $_.Status + " start=" + $_.StartType) }
Write-Output '=== 4. ccmsetup.log tail ==='
Get-Content 'C:\Windows\ccmsetup\Logs\ccmsetup.log' -Tail 15 -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_ }
Write-Output 'PHASE2_DONE'
