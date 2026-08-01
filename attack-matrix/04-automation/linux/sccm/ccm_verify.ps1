# Client state check (runs ON mbr02) — output to file
$out = @()
$out += 'CCMEXEC=' + (Get-Service CcmExec -ErrorAction SilentlyContinue).Status
$r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($r) {
  $out += 'CCM_SITE=' + $r.AssignedSiteCode
  $out += 'CCM_MP=' + $r.MP
  $out += 'CCM_VER=' + $r.SMSClientVersion
} else { $out += 'CCM_REG=MISSING' }
$out += 'CCM_DIR=' + (Test-Path 'C:\Windows\CCM')
$out += 'CCMSETUP_LOG_LAST=' + ((Get-Item 'C:\Windows\CCMSetup\Logs\ccmsetup.log' -ErrorAction SilentlyContinue).LastWriteTime)
$out | Out-File -FilePath 'C:\Windows\Temp\ccm_verify.txt' -Encoding ascii
