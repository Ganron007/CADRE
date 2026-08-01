# Post-reboot client registration check — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Write-Output '=== Wait 120s for services + client registration ==='
Start-Sleep -Seconds 120
Write-Output '=== 1. Services ==='
Write-Output ('  CCMEXEC=' + (Get-Service CcmExec -ErrorAction SilentlyContinue).Status)
Write-Output ('  SMS_EXEC=' + (Get-Service SMS_EXECUTIVE -ErrorAction SilentlyContinue).Status)
Write-Output '=== 2. CCM registry (assignment) ==='
$r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($r) {
  Write-Output ('  SITE=' + $r.AssignedSiteCode + ' | MP=' + $r.MP + ' | VER=' + $r.SMSClientVersion)
} else { Write-Output '  REG=MISSING' }
Write-Output '=== 3. root\ccm client ==='
try {
  $c = Get-CimInstance -Namespace root\CCM -ClassName SMS_Client -ErrorAction Stop
  Write-Output ('  VER=' + $c.ClientVersion + ' | Site=' + $c.SiteCode + ' | Assigned=' + $c.AssignedSiteCode + ' | MP=' + $c.AssignedMP)
} catch { Write-Output ('  ROOTCCM_ERR=' + $_.Exception.Message) }
Write-Output '=== 4. CCM dir + policy/reg logs ==='
Write-Output ('  CCM_DIR=' + (Test-Path 'C:\Windows\CCM'))
foreach ($l in @('C:\Windows\CCM\Logs\PolicyAgent.log','C:\Windows\CCM\Logs\LocationServices.log','C:\Windows\CCM\Logs\ClientIDManagerStartup.log')) {
  if (Test-Path $l) { Write-Output ('  LOG ' + (Split-Path $l -Leaf) + ': ' + (Get-Item $l).LastWriteTime) }
}
Write-Output '=== 5. SMS_R_System client flag ==='
$d = Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_R_System -Filter "Name='MBR02'" -ErrorAction SilentlyContinue
if ($d) { $d | ForEach-Object { Write-Output ('  RESOURCE: ' + $_.ResourceID + ' | client=' + $_.Client + ' | ver=' + $_.ClientVersion) } }
Write-Output 'POST_REBOOT_DONE'
