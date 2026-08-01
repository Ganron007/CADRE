# Retry SCCM client assignment on mbr02 (CONFIG, vagrant via WinRM) — now that NAT is available
$ErrorActionPreference = 'Continue'
Write-Output '=== Kill stuck ccmsetup ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 3
Write-Output '=== Launch ccmsetup (MP + sitecode, NAT on now) ==='
$p = Start-Process -FilePath 'C:\Windows\CCMSetup\ccmsetup.exe' -ArgumentList '/MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -PassThru -WindowStyle Hidden
Write-Output ('LAUNCH_PID=' + $p.Id)
Write-Output '=== Wait 180s ==='
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
Write-Output '=== ccmsetup.log tail ==='
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 25 | ForEach-Object { if ($_ -match '<![LOG\[(.*?)\]LOG') { Write-Output ('LOG: ' + $Matches[1]) } }
} else { Write-Output 'NO LOG' }
Write-Output 'RETRY_DONE'
