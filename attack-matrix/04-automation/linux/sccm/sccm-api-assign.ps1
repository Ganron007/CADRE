# Assign via official client API (SetAssignedSite) + force policy — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== GetAssignedSite() ==='
try {
  $r = ([wmiclass]"root\ccm:SMS_Client").GetAssignedSite()
  Write-Output ("  AssignedSite=" + $r.AssignedSite)
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== SetAssignedSite(CAD) ==='
try {
  $r2 = ([wmiclass]"root\ccm:SMS_Client").SetAssignedSite("CAD")
  Write-Output ("  SetAssignedSite ret=" + $r2.ReturnValue)
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== RequestMachinePolicy() ==='
try {
  $r3 = ([wmiclass]"root\ccm:SMS_Client").RequestMachinePolicy()
  Write-Output ("  RequestMachinePolicy ret=" + $r3.ReturnValue)
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== EvaluateMachinePolicy() ==='
try {
  $r4 = ([wmiclass]"root\ccm:SMS_Client").EvaluateMachinePolicy()
  Write-Output ("  EvaluateMachinePolicy ret=" + $r4.ReturnValue)
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Start-Sleep -Seconds 20

Write-Output '=== After trigger ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
$cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
Write-Output ("  CCM\AssignedSiteCode=" + $cp.AssignedSiteCode)
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))
Write-Output ("  SMS_CCM\Logs=" + (Test-Path 'C:\Program Files\SMS_CCM\Logs'))
if (Test-Path 'C:\Program Files\SMS_CCM\Logs') { Get-ChildItem 'C:\Program Files\SMS_CCM\Logs' -Filter '*.log' | Select-Object -First 10 | ForEach-Object { Write-Output ("  LOG: " + $_.Name) } }
Write-Output '=== LocationServices candidates now ==='
try {
  Get-WmiObject -Namespace root\ccm\LocationServices -Class SMS_ActiveMPCandidate -ErrorAction Stop | ForEach-Object { Write-Output ("  MP=" + $_.MP + " Type=" + $_.Type) }
  if (-not (Get-WmiObject -Namespace root\ccm\LocationServices -Class SMS_ActiveMPCandidate -ErrorAction SilentlyContinue)) { Write-Output '  (none)' }
} catch { Write-Output ("  ActiveMP ERROR: " + $_.Exception.Message) }
Write-Output 'APIASSIGN_DONE'
