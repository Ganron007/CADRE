# Complete SCCM client on mbr02 (CONFIG — runs as vagrant on mbr02)
$ErrorActionPreference = 'Continue'
Write-Output '=== Kill stuck ccmsetup ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 3
Write-Output '=== Launch ccmsetup with local source ==='
$cmd = 'C:\Windows\CCMSetup\ccmsetup.exe /source:"C:\Program Files\Microsoft Configuration Manager\Client" /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck'
$p = Start-Process -FilePath 'C:\Windows\CCMSetup\ccmsetup.exe' -ArgumentList '/source:"C:\Program Files\Microsoft Configuration Manager\Client" /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -PassThru -WindowStyle Hidden
Write-Output ('LAUNCH_PID=' + $p.Id)
Write-Output '=== Wait 150s ==='
Start-Sleep -Seconds 150
$svc = Get-Service CcmExec -ErrorAction SilentlyContinue
Write-Output ('CCMEXEC=' + $svc.Status)
$r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($r) {
  Write-Output ('CCM_SITE=' + $r.AssignedSiteCode)
  Write-Output ('CCM_MP=' + $r.MP)
  Write-Output ('CCM_VER=' + $r.SMSClientVersion)
} else { Write-Output 'CCM_REG=MISSING' }
Write-Output ('CCM_DIR=' + (Test-Path 'C:\Windows\CCM'))
Write-Output 'CONFIG_CLIENT_DONE'
