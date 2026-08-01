# COMPLETE wipe + fresh client install — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Write-Output '=== 1. Kill + remove client service/files/reg (redo) ==='
Get-Process ccmsetup,ccmexec,ccmsvc,scnotification -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3
sc.exe delete CcmExec 2>&1 | Out-Null
Remove-Item 'C:\Windows\CCM' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item 'C:\Program Files\SMS_CCM' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item 'C:\Windows\CCMSetup' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item 'HKLM:\SOFTWARE\Microsoft\CCM' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item 'HKLM:\SOFTWARE\Microsoft\SMS' -Recurse -Force -ErrorAction SilentlyContinue
Write-Output '=== 2. Delete root\ccm WMI namespace ==='
Get-WmiObject -Namespace root -Class __Namespace -Filter "Name='ccm'" -ErrorAction SilentlyContinue | ForEach-Object { try { $_.Delete(); Write-Output '  ROOTCCM_DELETED' } catch { Write-Output ('  DEL_ERR=' + $_.Exception.Message) } }
Write-Output '=== 3. Delete device record (fresh registration) ==='
Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_R_System -Filter "Name='MBR02'" -ErrorAction SilentlyContinue | ForEach-Object { try { $_.Delete(); Write-Output '  DEVICE_DELETED' } catch { Write-Output ('  DEV_ERR=' + $_.Exception.Message) } }
Write-Output '=== 4. Recreate ccmsetup + fresh install ==='
New-Item -ItemType Directory -Path 'C:\Windows\CCMSetup' -Force | Out-Null
Copy-Item 'C:\Program Files\Microsoft Configuration Manager\Client\ccmsetup.exe' 'C:\Windows\CCMSetup\ccmsetup.exe' -Force -ErrorAction SilentlyContinue
Set-Content -Path 'C:\Windows\Temp\ccm_fresh.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_fresh.cmd' -PassThru -WindowStyle Hidden
Write-Output ('  PID=' + $p.Id)
Write-Output '=== 5. Wait 5 min for install + assignment ==='
Start-Sleep -Seconds 300
Write-Output '=== 6. Verify ==='
$svc = Get-Service CcmExec -ErrorAction SilentlyContinue
Write-Output ('  CCMEXEC=' + $svc.Status)
$r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($r) { Write-Output ('  SITE=' + $r.AssignedSiteCode + ' | MP=' + $r.MP + ' | VER=' + $r.SMSClientVersion) } else { Write-Output '  REG=MISSING' }
Write-Output ('  CCM_DIR=' + (Test-Path 'C:\Windows\CCM'))
try {
  $c = Get-CimInstance -Namespace root\CCM -ClassName SMS_Client -ErrorAction Stop
  Write-Output ('  ROOTCCM: VER=' + $c.ClientVersion + ' | Site=' + $c.SiteCode + ' | Assigned=' + $c.AssignedSiteCode + ' | MP=' + $c.AssignedMP)
} catch { Write-Output ('  ROOTCCM_ERR=' + $_.Exception.Message) }
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('  LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 4 | ForEach-Object { $t = $_; if ($t.Length -gt 150) { $t = $t.Substring(0,150) }; Write-Output ('  ' + $t) }
}
Write-Output 'WIPE_DONE'
