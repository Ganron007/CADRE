# Verify client install completion — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Write-Output '=== Waiting 4 min for client install to finish ==='
Start-Sleep -Seconds 240
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
  Get-Content $log -Tail 5 | ForEach-Object { $t = $_; if ($t.Length -gt 150) { $t = $t.Substring(0,150) }; Write-Output ('  ' + $t) }
}
Write-Output 'VERIFY_DONE'
