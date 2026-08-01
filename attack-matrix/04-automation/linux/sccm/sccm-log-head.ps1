# Head of ccmsetup.log + reboot-pending state on mbr02 — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$log = 'C:\Windows\ccmsetup\Logs\ccmsetup.log'
Write-Output '=== HEAD 60 lines of ccmsetup.log (most recent install start) ==='
Get-Content $log -TotalCount 60 | ForEach-Object { Write-Output $_ }
Write-Output '=== Pending reboot indicators ==='
$rebootPending = $false
try {
  $u = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' -ErrorAction SilentlyContinue
  if ($u) { $rebootPending = $true; Write-Output '  WU RebootRequired key present' }
} catch {}
try {
  $s = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
  if ($s.PendingFileRenameOperations) { $rebootPending = $true; Write-Output '  PendingFileRenameOperations present' }
} catch {}
try {
  $c = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' -ErrorAction SilentlyContinue
  if ($c) { $rebootPending = $true; Write-Output '  CBS RebootPending present' }
} catch {}
Write-Output ("  REBOOT_PENDING=" + $rebootPending)
Write-Output '=== MSI pending reboot (Installer key) ==='
try { $i = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\InProgress' -ErrorAction SilentlyContinue; Write-Output ('  InProgress count=' + @($i).Count) } catch { Write-Output '  InProgress n/a' }
Write-Output '=== Client MSI product check ==='
$p = Get-WmiObject -Class Win32_Product -Filter "Name like 'Configuration Manager Client%'" -ErrorAction SilentlyContinue
if ($p) { $p | ForEach-Object { Write-Output ("  PROD: " + $_.Name + " | " + $_.Version + " | " + $_.InstallSource) } } else { Write-Output '  No CM client product found in WMI' }
Write-Output 'HEAD_DONE'
