# Grab real error evidence from mbr02 client logs — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Write-Output '=== ccmsetup.log location check ==='
foreach ($p in @('C:\Windows\ccmsetup\Logs\ccmsetup.log','C:\Windows\CCM\Logs\ccmsetup.log','C:\Windows\System32\ccmsetup\Logs\ccmsetup.log')) {
  if (Test-Path $p) { Write-Output ("  EXISTS: $p"); $L = $p; break }
}
if ($L) {
  Write-Output '=== LAST 80 LINES of ccmsetup.log ==='
  Get-Content $L -Tail 80 | ForEach-Object { Write-Output $_ }
} else { Write-Output '  NO ccmsetup.log found' }
Write-Output '=== C:\Windows\ccmsetup dir ==='
if (Test-Path 'C:\Windows\ccmsetup') { Get-ChildItem 'C:\Windows\ccmsetup' -Recurse -Depth 1 | Select-Object -First 40 | ForEach-Object { Write-Output ('  ' + $_.FullName) } } else { Write-Output '  NO C:\Windows\ccmsetup' }
Write-Output '=== Client registry state ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
if (Test-Path $c) {
  $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
  Write-Output ("  CCM exists. AssignedSiteCode=" + $cp.AssignedSiteCode + " SMS_MP=" + $cp.SMS_MP + " CcmExecServiceStartType=" + $cp.CcmExecServiceStartType)
} else { Write-Output '  CCM reg GONE' }
$s = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
if (Test-Path $s) {
  $sp = Get-ItemProperty $s -ErrorAction SilentlyContinue
  Write-Output ("  SMS\Mobile Client exists. AssignedSiteCode=" + $sp.AssignedSiteCode + " SMSUniqueIdentifier=" + $sp.SMSUniqueIdentifier)
} else { Write-Output '  SMS\Mobile Client GONE' }
$cc = 'HKLM:\SOFTWARE\Microsoft\CCMSetup'
if (Test-Path $cc) { $ccp = Get-ItemProperty $cc -ErrorAction SilentlyContinue; Write-Output ("  CCMSetup reg exists. InstallCmdLine=" + $ccp.InstallCmdLine + " LastError=" + $ccp.LastError) } else { Write-Output '  CCMSetup reg GONE' }
Write-Output '=== CcmExec service ==='
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec: " + $_.Status) }
Write-Output '=== root\ccm namespace ==='
try { $ns = Get-WmiObject -Namespace 'root\ccm' -Class __NAMESPACE -ErrorAction Stop | Select-Object -ExpandProperty Name; Write-Output ("  root\ccm OK. children=" + ($ns -join ',')) } catch { Write-Output ("  root\ccm ERROR: " + $_.Exception.Message) }
Write-Output 'LOG_EVIDENCE_DONE'
