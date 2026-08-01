# Round 7: introspect join class schemas + fix membership — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
$ns = 'root\SMS\site_CAD'
Write-Output '=== SMS_BoundaryGroupMembers schema ==='
(Get-CimClass -ClassName SMS_BoundaryGroupMembers -Namespace $ns -ErrorAction SilentlyContinue).CimClassProperties | ForEach-Object { Write-Output ('  ' + $_.Name + ' : ' + $_.CimType) }
Write-Output '=== SMS_BoundaryGroupSiteSystems schema ==='
(Get-CimClass -ClassName SMS_BoundaryGroupSiteSystems -Namespace $ns -ErrorAction SilentlyContinue).CimClassProperties | ForEach-Object { Write-Output ('  ' + $_.Name + ' : ' + $_.CimType) }
$gid = (Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroup -Filter "Name='CADRE-Lab-BG'" -ErrorAction SilentlyContinue).GroupID
$bid = (Get-WmiObject -Namespace $ns -Class SMS_Boundary -Filter "Value='192.168.77.0/24'" -ErrorAction SilentlyContinue).BoundaryID
Write-Output ('GID=' + $gid + ' BID=' + $bid)
Write-Output '=== Try member creation (autodetect) ==='
if ($gid -and $bid) {
  try {
    $props = @{}
    $bm = (Get-CimClass -ClassName SMS_BoundaryGroupMembers -Namespace $ns).CimClassProperties
    $gProp = ($bm | Where-Object { $_.Name -match 'Group' } | Select-Object -First 1).Name
    $bProp = ($bm | Where-Object { $_.Name -match 'Boundary' } | Select-Object -First 1).Name
    Write-Output ('  using group prop=' + $gProp + ' boundary prop=' + $bProp)
    if ($gProp -and $bProp) {
      $ph = @{ }
      $ph[$gProp] = [uint32]$gid
      $ph[$bProp] = [uint32]$bid
      New-CimInstance -ClassName SMS_BoundaryGroupMembers -Namespace $ns -Property $ph -ErrorAction Stop | Out-Null
      Write-Output '  MEMBER_BOUNDARY_ADDED'
    }
  } catch { Write-Output ('  MEMB_ERR=' + $_.Exception.Message) }
  try {
    $ss = (Get-CimClass -ClassName SMS_BoundaryGroupSiteSystems -Namespace $ns).CimClassProperties
    $gProp2 = ($ss | Where-Object { $_.Name -match 'Group' } | Select-Object -First 1).Name
    $sProp = ($ss | Where-Object { $_.Name -match 'NAL|Server|SiteSystem' } | Select-Object -First 1).Name
    Write-Output ('  site-sys props: group=' + $gProp2 + ' server=' + $sProp)
    if ($gProp2 -and $sProp) {
      $nal = '["Display=\\mbr02.range.local\"]MSWNET:["SMS_SITE=CAD"]\\mbr02.range.local\'
      $ph2 = @{ }
      $ph2[$gProp2] = [uint32]$gid
      $ph2[$sProp] = $nal
      New-CimInstance -ClassName SMS_BoundaryGroupSiteSystems -Namespace $ns -Property $ph2 -ErrorAction Stop | Out-Null
      Write-Output '  MEMBER_SITESYSTEM_ADDED'
    }
  } catch { Write-Output ('  SS_ERR=' + $_.Exception.Message) }
}
Write-Output '=== Verify members ==='
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupMembers -Filter "BoundaryGroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_B: ' + $_.BoundaryID) }
Get-WmiObject -Namespace $ns -Class SMS_BoundaryGroupSiteSystems -Filter "BoundaryGroupID=$gid" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('MEMB_SS: ' + $_.ServerNALPath) }
Write-Output 'CFG_DONE'
