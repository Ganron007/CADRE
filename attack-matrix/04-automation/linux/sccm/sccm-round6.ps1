# Round 6: boundary (correct types) + group members + clean ccmsetup — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
$ns = 'root\SMS\site_CAD'

Write-Output '=== Create boundary (correct schema types) ==='
$bid = $null
try {
  $existing = Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue
  if ($existing) { $bid = $existing.BoundaryID; Write-Output ('BOUNDARY_EXISTS id=' + $bid) }
  else {
    $b = New-CimInstance -ClassName SMS_Boundary -Namespace $ns -Property @{
      DisplayName = 'CADRE-Lab-Subnet'
      BoundaryType = [uint32]0
      Value = '192.168.77.0/24'
      DefaultSiteCode = [string[]]@('CAD')
    } -ErrorAction Stop
    $got = Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue
    if ($got) { $bid = $got.BoundaryID }
    Write-Output ('BOUNDARY_CREATED id=' + $bid)
  }
} catch { Write-Output ('BOUNDARY_ERR=' + $_.Exception.Message) }

$gid = (Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue).GroupID
if ($bid -and $gid) {
  Write-Output '=== Add boundary member ==='
  try {
    New-CimInstance -ClassName SMS_BoundaryGroupMembers -Namespace $ns -Property @{
      BoundaryGroupID = [uint32]$gid
      BoundaryID = [uint32]$bid
    } -ErrorAction Stop | Out-Null
    Write-Output 'MEMBER_BOUNDARY_ADDED'
  } catch { Write-Output ('MEMB_ERR=' + $_.Exception.Message) }
  Write-Output '=== Add site system member ==='
  try {
    $nal = '["Display=\\mbr02.range.local\"]MSWNET:["SMS_SITE=CAD"]\\mbr02.range.local\'
    New-CimInstance -ClassName SMS_BoundaryGroupSiteSystems -Namespace $ns -Property @{
      BoundaryGroupID = [uint32]$gid
      ServerNALPath = $nal
    } -ErrorAction Stop | Out-Null
    Write-Output 'MEMBER_SITESYSTEM_ADDED'
  } catch { Write-Output ('SS_ERR=' + $_.Exception.Message) }
}
Write-Output '=== Verify boundary config ==='
Get-WmiObject -Namespace $ns -Class SMS_Boundary -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('BOUNDARY: ' + $_.DisplayName + ' | ' + $_.Value + ' | type=' + $_.BoundaryType) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupMembers -Filter "BoundaryGroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_B: ' + $_.BoundaryID) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupSiteSystems -Filter "BoundaryGroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_SS: ' + $_.ServerNALPath) }
Write-Output '=== Launch ccmsetup (staged cmd, boundary now present) ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 2
Set-Content -Path 'C:\Windows\Temp\ccm_run.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_run.cmd' -PassThru -WindowStyle Hidden
Write-Output ('LAUNCH_PID=' + $p.Id)
Start-Sleep -Seconds 30
$alive = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
Write-Output ('ALIVE_30S=' + [bool]$alive)
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 5
}
Write-Output 'CFG_DONE'
