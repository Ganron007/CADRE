# Round 8: add boundary + site system to group via COM SWbemLocator — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
$ns = 'root\SMS\site_CAD'
$wmi = New-Object -ComObject WbemScripting.SWbemLocator
$svc = $wmi.ConnectServer('localhost', $ns)
$gid = (Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue).GroupID
$bid = (Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue).BoundaryID
Write-Output ('GID=' + $gid + ' BID=' + $bid)
if ($gid -and $bid) {
  try {
    $bg = $svc.Get("SMS_BoundaryGroup.GroupID=$gid")
    $bg.AddBoundary([uint32]$bid)
    Write-Output 'BOUNDARY_ADDED'
  } catch { Write-Output ('ADD_ERR=' + $_.Exception.Message) }
  try {
    $bg2 = $svc.Get("SMS_BoundaryGroup.GroupID=$gid")
    $nal = '["Display=\\mbr02.range.local\"]MSWNET:["SMS_SITE=CAD"]\\mbr02.range.local\'
    $bg2.AddSiteSystem($nal)
    Write-Output 'SITESYSTEM_ADDED'
  } catch { Write-Output ('SS_ERR=' + $_.Exception.Message) }
}
Write-Output '=== Verify members ==='
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupMembers -Filter "GroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_B: ' + $_.BoundaryID) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupSiteSystems -Filter "GroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_SS: ' + $_.ServerNALPath) }
Write-Output '=== Launch ccmsetup (boundary group complete) ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 2
Set-Content -Path 'C:\Windows\Temp\ccm_run.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_run.cmd' -PassThru -WindowStyle Hidden
Write-Output ('LAUNCH_PID=' + $p.Id)
Start-Sleep -Seconds 40
$alive = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
Write-Output ('ALIVE_40S=' + [bool]$alive)
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 5 | ForEach-Object { if ($_.Length -gt 0) { $s = $_; if ($s -match 'LOG\]!>.*component="([^"]+)".*type="(\d)".*file="([^"]+)"') { Write-Output ('  [' + $Matches[2] + '] ' + $Matches[1] + ' ' + $Matches[3]) } } }
}
Write-Output 'CFG_DONE'
