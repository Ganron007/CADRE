# PHASE 1B: force-disable CcmExec + kill + clean + reboot — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== 1. Disable + stop client services ==='
foreach ($svc in @('CcmExec','ccmsetup','CmRcService','smstsmgr')) {
  sc.exe config $svc start= disabled | Out-Null
  sc.exe stop $svc | Out-Null
  Write-Output ("  disabled+stopped " + $svc)
}
Start-Sleep -Seconds 3

Write-Output '=== 2. Force kill remaining processes ==='
taskkill /F /IM CcmExec.exe /T 2>&1 | Out-Null
taskkill /F /IM ccmsetup.exe /T 2>&1 | Out-Null
Start-Sleep -Seconds 3
Get-Process CcmExec, ccmsetup -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  STILL RUNNING: " + $_.Name) }
Write-Output '  kill done'

Write-Output '=== 3. Remove dirs (with retries) ==='
foreach ($d in @('C:\Program Files\SMS_CCM','C:\Windows\ccmsetup','C:\Windows\CCM','C:\Windows\ccmcache')) {
  for ($i=0; $i -lt 3; $i++) {
    if (Test-Path $d) { Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 2 }
  }
  Write-Output ("  " + $d + " exists=" + (Test-Path $d))
}

Write-Output '=== 4. Remove client registry ==='
foreach ($k in @('HKLM:\SOFTWARE\Microsoft\CCM','HKLM:\SOFTWARE\Microsoft\CCMSetup','HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client')) {
  for ($i=0; $i -lt 3; $i++) {
    if (Test-Path $k) { Remove-Item $k -Recurse -Force -ErrorAction SilentlyContinue; Start-Sleep -Seconds 1 }
  }
  Write-Output ("  " + $k + " exists=" + (Test-Path $k))
}

Write-Output '=== 5. Remove root\ccm namespace ==='
try {
  $ns = Get-WmiObject -Namespace root -Class __Namespace -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'ccm' }
  if ($ns) { $ns.Delete(); Write-Output '  root\ccm deleted' } else { Write-Output '  root\ccm absent' }
} catch { Write-Output ("  ns ERROR: " + $_.Exception.Message) }

Write-Output '=== 6. Verify clean ==='
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec service: " + $_.Status + " start=" + $_.StartType) }
Write-Output ("  SMS_CCM=" + (Test-Path 'C:\Program Files\SMS_CCM'))
Write-Output ("  CCM_REG=" + (Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM'))

Write-Output '=== 7. Reboot ==='
shutdown /r /t 5 /c "CADRE client clean reboot" /f
Write-Output 'PHASE1B_DONE'
