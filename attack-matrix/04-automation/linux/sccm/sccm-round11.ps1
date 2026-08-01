# Round 11: add site system to boundary group + retry client — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== Set-CMBoundaryGroup params ==='
try {
  (Get-Command Set-CMBoundaryGroup -ErrorAction Stop).Parameters.Keys | Where-Object { $_ -match 'SiteSystem|Server|Add' } | ForEach-Object { Write-Output ('PARAM: ' + $_) }
} catch { Write-Output ('PARAM_ERR=' + $_.Exception.Message) }

Write-Output '=== Add mbr02 as site system to group ==='
try {
  Set-CMBoundaryGroup -Name 'CADRE-Lab-BG' -AddSiteSystem 'mbr02.range.local' -ErrorAction Stop
  Write-Output 'SITESYSTEM_ADDED'
} catch { Write-Output ('SS_ERR=' + $_.Exception.Message) }

Write-Output '=== Verify group site systems ==='
try {
  Get-CMBoundaryGroupSiteSystem -BoundaryGroupName 'CADRE-Lab-BG' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('GSS: ' + $_.ServerName) }
} catch { Write-Output ('GSS_ERR=' + $_.Exception.Message) }

Write-Output '=== Retry ccmsetup (boundary group now has boundary + site system) ==='
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
  $tail = Get-Content $log -Tail 8
  foreach ($line in $tail) { if ($line -match '<![LOG\[(.*?)\]LOG') { Write-Output ('LOG: ' + $Matches[1].Substring(0, [Math]::Min(160, $Matches[1].Length))) } }
}
Write-Output 'CFG_DONE'
