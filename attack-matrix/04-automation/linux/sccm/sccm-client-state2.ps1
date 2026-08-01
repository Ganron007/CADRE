# Client-side authoritative state on mbr02 — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== SMS_Client class (root\ccm) ==='
try {
  $client = Get-WmiObject -Namespace root\ccm -Class SMS_Client -ErrorAction Stop
  Write-Output ("  ClientVersion=" + $client.ClientVersion)
  Write-Output ("  ClientFlags=" + $client.ClientFlags)
  Write-Output ("  ClientType=" + $client.ClientType)
  Write-Output ("  SMSState=" + $client.SMSState)
  Write-Output ("  Installed=" + $client.Installed)
  Write-Output ("  AssignedSiteCode(prop)=" + $client.AssignedSiteCode)
  Write-Output ("  AssignedSiteCodeOverridden=" + $client.AssignedSiteCodeOverridden)
  Write-Output ("  SMSUniqueIdentifier=" + $client.SMSUniqueIdentifier)
} catch { Write-Output ("  SMS_Client ERROR: " + $_.Exception.Message) }

Write-Output '=== GetAssignedSiteInfo() ==='
try {
  $r = ([wmiclass]"root\ccm:SMS_Client").GetAssignedSiteInfo()
  Write-Output ("  AssignedSiteCode=" + $r.AssignedSiteCode)
  Write-Output ("  AssignedSiteName=" + $r.AssignedSiteName)
  Write-Output ("  AssignedSiteServer=" + $r.AssignedSiteServer)
  Write-Output ("  MP=" + $r.MP)
  Write-Output ("  MPName=" + $r.MPName)
} catch { Write-Output ("  GetAssignedSiteInfo ERROR: " + $_.Exception.Message) }

Write-Output '=== LocationServices: ActiveMP candidates ==='
try {
  Get-WmiObject -Namespace root\ccm\LocationServices -Class SMS_ActiveMPCandidate -ErrorAction Stop | ForEach-Object { Write-Output ("  MP=" + $_.MP + " Type=" + $_.Type + " Version=" + $_.Version) }
} catch { Write-Output ("  ActiveMP ERROR: " + $_.Exception.Message) }

Write-Output '=== LocationServices: MP candidates ==='
try {
  Get-WmiObject -Namespace root\ccm\LocationServices -Class SMS_MPCandidates -ErrorAction Stop | ForEach-Object { Write-Output ("  MP=" + $_.Name) }
} catch { Write-Output ("  MPCandidates ERROR: " + $_.Exception.Message) }

Write-Output '=== LocationServices: Current MP ==='
try {
  Get-WmiObject -Namespace root\ccm\LocationServices -Class SMS_CurrentMP -ErrorAction Stop | ForEach-Object { Write-Output ("  CurrentMP=" + $_.MP) }
} catch { Write-Output ("  CurrentMP ERROR: " + $_.Exception.Message) }

Write-Output '=== Policy Machine ActualConfig ==='
try {
  Get-WmiObject -Namespace root\ccm\Policy\Machine -Class ActualConfig -ErrorAction Stop | ForEach-Object { Write-Output ("  Key=" + $_.KeyName) }
} catch { Write-Output ("  ActualConfig ERROR: " + $_.Exception.Message) }

Write-Output '=== Event log: SMS Client (last 15) ==='
try {
  Get-WinEvent -LogName 'SMS Client' -MaxEvents 15 -ErrorAction Stop | ForEach-Object { Write-Output ("  [" + $_.TimeCreated + "] " + $_.LevelDisplayName + " " + $_.Id + ": " + (($_.Message -replace "`r`n"," ").Substring(0, [Math]::Min(180, ($_.Message -replace "`r`n"," ").Length)))) }
} catch { Write-Output ("  SMS Client log ERROR: " + $_.Exception.Message) }

Write-Output '=== CCM dir / cache / logs ==='
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))
Write-Output ("  CCMLOGS=" + (Test-Path 'C:\Windows\CCM\Logs'))
Write-Output ("  CCMCACHE=" + (Test-Path 'C:\Windows\ccmcache'))
if (Test-Path 'C:\Windows\CCM\Logs') { Get-ChildItem 'C:\Windows\CCM\Logs' -Filter '*.log' | Select-Object -First 15 | ForEach-Object { Write-Output ("  LOG: " + $_.Name) } }
Write-Output 'CLIENTSTATE_DONE'
