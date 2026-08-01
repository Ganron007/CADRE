# SCCM client state check on mbr02 (CONFIG, as vagrant)
$s = Get-Service CcmExec -ErrorAction SilentlyContinue
Write-Output ('CCMEXEC=' + $s.Status)
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
  $tail = Get-Content $log -Tail 12
  foreach ($line in $tail) { if ($line -match '<![LOG\[(.*?)\]LOG') { Write-Output ('LOG: ' + $Matches[1]) } }
}
Write-Output 'STATE_DONE'
