# FINAL consolidated fix: boundary-group site system + client package distribution + ccmsetup
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue
$ns = 'root\SMS\site_CAD'

Write-Output '=== 1. Boundary group members (WMI read, reliable) ==='
$gid = (Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue).GroupID
Write-Output ('GID=' + $gid)
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupMembers -Filter "GroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('  BOUNDARY_IN_GROUP: ' + $_.BoundaryID) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupSiteSystems -Filter "GroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('  SITESYSTEM_IN_GROUP: ' + $_.ServerNALPath) }

Write-Output '=== 2. Ensure mbr02 is a site system in the group ==='
$inGroup = @(Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupSiteSystems -Filter "GroupID=$gid" -ErrorAction SilentlyContinue).Count
if ($inGroup -eq 0) {
  try { Set-CMBoundaryGroup -Name 'CADRE-Lab-BG' -AddSiteSystemServerName 'mbr02.range.local' -ErrorAction Stop; Write-Output '  SITESYSTEM_ADDED' }
  catch { Write-Output ('  SS_ERR=' + $_.Exception.Message) }
} else { Write-Output '  SITESYSTEM_ALREADY_PRESENT' }

Write-Output '=== 3. Client package CAD00003 distribution status ==='
try {
  $dps = Get-WmiObject -Namespace $ns -Class SMS_DistributionDPStatus -Filter "PackageID='CAD00003'" -ErrorAction SilentlyContinue
  if ($dps) { $dps | ForEach-Object { Write-Output ('  DP_STATUS: ' + $_.DPName + ' | ' + $_.State + ' | ver=' + $_.Version) } }
  else { Write-Output '  NO_DP_STATUS_ROWS (package never distributed)' }
} catch { Write-Output ('  DPS_ERR=' + $_.Exception.Message) }

Write-Output '=== 4. Distribute client package to mbr02 if needed ==='
$distributed = $false
try {
  $st = Get-WmiObject -Namespace $ns -Class SMS_DistributionDPStatus -Filter "PackageID='CAD00003'" -ErrorAction SilentlyContinue
  foreach ($s in $st) { if ($s.State -eq 0 -or $s.State -eq 1) { $distributed = $true } }
} catch {}
if (-not $distributed) {
  try {
    Start-CMContentDistribution -PackageId 'CAD00003' -DistributionPointName 'mbr02.range.local' -ErrorAction Stop
    Write-Output '  CONTENT_DISTRIBUTION_STARTED (will take a few minutes)'
  } catch { Write-Output ('  DIST_ERR=' + $_.Exception.Message) }
} else { Write-Output '  CONTENT_ALREADY_DISTRIBUTED' }

Write-Output '=== 5. Run ccmsetup (boundary + group + content now in place) ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 2
Set-Content -Path 'C:\Windows\Temp\ccm_run.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_run.cmd' -PassThru -WindowStyle Hidden
Write-Output ('  LAUNCH_PID=' + $p.Id)
Start-Sleep -Seconds 240
$svc = Get-Service CcmExec -ErrorAction SilentlyContinue
Write-Output ('  CCMEXEC=' + $svc.Status)
$r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($r) {
  Write-Output ('  CCM_SITE=' + $r.AssignedSiteCode)
  Write-Output ('  CCM_MP=' + $r.MP)
  Write-Output ('  CCM_VER=' + $r.SMSClientVersion)
} else { Write-Output '  CCM_REG=MISSING' }
Write-Output ('  CCM_DIR=' + (Test-Path 'C:\Windows\CCM'))
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('  LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 3 | ForEach-Object { $t = $_; if ($t.Length -gt 120) { $t = $t.Substring(0,120) }; Write-Output ('  LOG: ' + $t) }
}
Write-Output 'FINAL_DONE'
