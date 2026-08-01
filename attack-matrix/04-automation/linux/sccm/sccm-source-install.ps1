# Clean /source client install (bypasses DP entirely) — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Write-Output '=== 1. Kill ccmsetup ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 2
$still = tasklist | findstr /i ccmsetup
if ($still) { Write-Output ('  STILL=' + $still) } else { Write-Output '  DEAD' }
Write-Output '=== 2. Launch ccmsetup /source via staged cmd ==='
Set-Content -Path 'C:\Windows\Temp\ccm_source.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /source:"C:\Program Files\Microsoft Configuration Manager\Client" /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_source.cmd' -PassThru -WindowStyle Hidden
Write-Output ('  PID=' + $p.Id)
Start-Sleep -Seconds 30
$alive = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
Write-Output ('  ALIVE_30S=' + [bool]$alive)
Write-Output '=== 3. Log tail (does it get past location?) ==='
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('  LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 6 | ForEach-Object { $t = $_; if ($t.Length -gt 150) { $t = $t.Substring(0,150) }; Write-Output ('  ' + $t) }
}
Write-Output '=== 4. Wait 3 more min for install ==='
Start-Sleep -Seconds 180
$svc = Get-Service CcmExec -ErrorAction SilentlyContinue
Write-Output ('  CCMEXEC=' + $svc.Status)
$r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($r) {
  Write-Output ('  CCM_SITE=' + $r.AssignedSiteCode)
  Write-Output ('  CCM_MP=' + $r.MP)
  Write-Output ('  CCM_VER=' + $r.SMSClientVersion)
} else { Write-Output '  CCM_REG=MISSING' }
Write-Output ('  CCM_DIR=' + (Test-Path 'C:\Windows\CCM'))
Write-Output 'SOURCE_INSTALL_DONE'
