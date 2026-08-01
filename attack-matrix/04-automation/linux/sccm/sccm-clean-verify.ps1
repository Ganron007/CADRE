# PHASE 1C: post-reboot cleanup verification — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== Post-reboot state ==='
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec: " + $_.Status + " start=" + $_.StartType) }
Get-Service ccmsetup -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  ccmsetup svc: " + $_.Status) }
Get-Process CcmExec, ccmsetup -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  PROC: " + $_.Name) }

Write-Output '=== Retry remove SMS_CCM + CCM reg ==='
if (Test-Path 'C:\Program Files\SMS_CCM') {
  Get-ChildItem 'C:\Program Files\SMS_CCM' -Force -ErrorAction SilentlyContinue | Select-Object -First 10 | ForEach-Object { Write-Output ("  still has: " + $_.Name) }
  Remove-Item 'C:\Program Files\SMS_CCM' -Recurse -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 3
  Write-Output ("  SMS_CCM exists=" + (Test-Path 'C:\Program Files\SMS_CCM'))
} else { Write-Output '  SMS_CCM absent' }

if (Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM') {
  Remove-Item 'HKLM:\SOFTWARE\Microsoft\CCM' -Recurse -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 2
  Write-Output ("  CCM reg exists=" + (Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM'))
} else { Write-Output '  CCM reg absent' }

Write-Output '=== Verify MSI products gone ==='
$p = Get-WmiObject -Class Win32_Product -Filter "Name like 'Configuration Manager%'" -ErrorAction SilentlyContinue
if ($p) { $p | ForEach-Object { Write-Output ("  STILL: " + $_.Name) } } else { Write-Output '  no CM products' }
Write-Output 'PHASE1C_DONE'
