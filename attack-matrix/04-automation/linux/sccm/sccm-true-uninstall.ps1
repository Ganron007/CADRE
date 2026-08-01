# PHASE 1: TRUE full client uninstall via msiexec /x + artifact cleanup — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== 1. Stop client services ==='
Get-Service CcmExec -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
Get-Service ccmsetup -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
Get-Process ccmsetup, CcmExec -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Write-Output '  services stopped'

Write-Output '=== 2. MSI product uninstall (client product code) ==='
$code = '{37710CBB-5069-4074-89DA-14F36FF16C52}'
$p = Start-Process msiexec.exe -ArgumentList "/x $code /qn /norestart" -Wait -PassThru
Write-Output ("  msiexec exit=" + $p.ExitCode)

Write-Output '=== 3. Check remaining products ==='
$prod = Get-WmiObject -Class Win32_Product -Filter "Name like 'Configuration Manager Client%'" -ErrorAction SilentlyContinue
if ($prod) { $prod | ForEach-Object { Write-Output ("  STILL INSTALLED: " + $_.IdentifyingNumber) } } else { Write-Output '  client product gone' }

Write-Output '=== 4. Remove residual dirs ==='
foreach ($d in @('C:\Program Files\SMS_CCM','C:\Windows\CCM','C:\Windows\ccmcache','C:\Windows\ccmsetup')) {
  if (Test-Path $d) { Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue; Write-Output ("  removed " + $d) } else { Write-Output ("  absent " + $d) }
}

Write-Output '=== 5. Remove client registry keys ==='
foreach ($k in @('HKLM:\SOFTWARE\Microsoft\CCM','HKLM:\SOFTWARE\Microsoft\CCMSetup','HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client')) {
  if (Test-Path $k) { Remove-Item $k -Recurse -Force -ErrorAction SilentlyContinue; Write-Output ("  removed reg " + $k) } else { Write-Output ("  absent reg " + $k) }
}

Write-Output '=== 6. Remove root\ccm WMI namespace ==='
try {
  Get-WmiObject -Namespace root -Class __Namespace -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'ccm' } | ForEach-Object { $_.Delete(); Write-Output '  root\ccm namespace deleted' }
} catch { Write-Output ("  ccm ns delete ERROR: " + $_.Exception.Message) }

Write-Output '=== 7. Verify clean ==='
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec STILL: " + $_.Status) }
Write-Output ("  SMS_CCM=" + (Test-Path 'C:\Program Files\SMS_CCM'))
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))
Write-Output ("  CCM_REG=" + (Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM'))
Write-Output ("  ROOTCCM=" + (Test-Path 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'))
Write-Output 'PHASE1_DONE'
