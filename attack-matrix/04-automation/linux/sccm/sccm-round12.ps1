# Round 12: add site system (correct param) + retry client — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== Add mbr02 as site system to group (AddSiteSystemServerName) ==='
try {
  Set-CMBoundaryGroup -Name 'CADRE-Lab-BG' -AddSiteSystemServerName 'mbr02.range.local' -ErrorAction Stop
  Write-Output 'SITESYSTEM_ADDED'
} catch { Write-Output ('SS_ERR=' + $_.Exception.Message) }

Write-Output '=== Verify group site systems ==='
try {
  $g = Get-CMBoundaryGroup -Name 'CADRE-Lab-BG' -ErrorAction Stop
  $g | Get-CMBoundaryGroupSiteSystem -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('GSS: ' + $_.ServerName + ' | ' + $_.NALPath) }
} catch { Write-Output ('GSS_ERR=' + $_.Exception.Message) }

Write-Output '=== Retry ccmsetup ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 2
Set-Content -Path 'C:\Windows\Temp\ccm_run.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_run.cmd' -PassThru -WindowStyle Hidden
Write-Output ('LAUNCH_PID=' + $p.Id)
Start-Sleep -Seconds 180
$svc = Get-Service CcmExec -ErrorAction SilentlyContinue
Write-Output ('CCMEXEC=' + $svc.Status)
$r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($r) {
  Write-Output ('CCM_SITE=' + $r.AssignedSiteCode)
  Write-Output ('CCM_MP=' + $r.MP)
  Write-Output ('CCM_VER=' + $r.SMSClientVersion)
} else { Write-Output 'CCM_REG=MISSING' }
Write-Output ('CCM_DIR=' + (Test-Path 'C:\Windows\CCM'))
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Write-Output '--- raw log tail 6 ---'
  Get-Content $log -Tail 6
}
Write-Output 'CFG_DONE'
