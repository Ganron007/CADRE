# CLEAN client reinstall on mbr02 (remove broken state, fresh install) — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Write-Output '=== 1. Kill client processes ==='
Get-Process ccmsetup,ccmexec,ccmsvc,scnotification -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3
Write-Output '=== 2. Remove CcmExec service ==='
Stop-Service CcmExec -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
sc.exe delete CcmExec 2>&1 | Out-Null
Start-Sleep -Seconds 2
Write-Output '=== 3. Remove client files ==='
Remove-Item 'C:\Windows\CCM' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item 'C:\Program Files\SMS_CCM' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item 'C:\Windows\CCMSetup' -Recurse -Force -ErrorAction SilentlyContinue
Write-Output '=== 4. Remove client registry ==='
Remove-Item 'HKLM:\SOFTWARE\Microsoft\CCM' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item 'HKLM:\SOFTWARE\Microsoft\SMS' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item 'HKLM:\SOFTWARE\Microsoft\SystemCertificates\SMS\Certificates' -Recurse -Force -ErrorAction SilentlyContinue
Write-Output '=== 5. Recreate ccmsetup folder (from client source) ==='
New-Item -ItemType Directory -Path 'C:\Windows\CCMSetup' -Force | Out-Null
Copy-Item 'C:\Program Files\Microsoft Configuration Manager\Client\ccmsetup.exe' 'C:\Windows\CCMSetup\ccmsetup.exe' -Force -ErrorAction SilentlyContinue
Write-Output ('  CCMSETUP_EXE=' + (Test-Path 'C:\Windows\CCMSetup\ccmsetup.exe'))
Write-Output '=== 6. Fresh install ==='
Set-Content -Path 'C:\Windows\Temp\ccm_fresh.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_fresh.cmd' -PassThru -WindowStyle Hidden
Write-Output ('  PID=' + $p.Id)
Start-Sleep -Seconds 60
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('  LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 5 | ForEach-Object { $t = $_; if ($t.Length -gt 150) { $t = $t.Substring(0,150) }; Write-Output ('  ' + $t) }
}
Write-Output 'CLEAN_INSTALL_LAUNCHED'
