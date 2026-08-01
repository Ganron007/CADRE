# Restart CcmExec to complete client registration + verify assignment — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Write-Output '=== 1. Restart CcmExec ==='
try {
  Restart-Service -Name CcmExec -Force -ErrorAction Stop
  Write-Output '  RESTARTED'
} catch { Write-Output ('  ERR=' + $_.Exception.Message) }
Start-Sleep -Seconds 180
Write-Output '=== 2. root\ccm client ==='
try {
  $c = Get-CimInstance -Namespace root\CCM -ClassName SMS_Client -ErrorAction Stop
  Write-Output ('  VER=' + $c.ClientVersion + ' | Site=' + $c.SiteCode + ' | Assigned=' + $c.AssignedSiteCode + ' | MP=' + $c.AssignedMP)
} catch { Write-Output ('  ROOTCCM_ERR=' + $_.Exception.Message) }
Write-Output '=== 3. CCM registry ==='
$r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($r) { Write-Output ('  SITE=' + $r.AssignedSiteCode + ' | MP=' + $r.MP + ' | VER=' + $r.SMSClientVersion) } else { Write-Output '  REG=MISSING' }
Write-Output '=== 4. CCM dir + client policy log ==='
Write-Output ('  CCM_DIR=' + (Test-Path 'C:\Windows\CCM'))
$pol = 'C:\Windows\CCM\Logs\PolicyAgent.log'
if (Test-Path $pol) {
  Write-Output ('  POLICY_LAST=' + (Get-Item $pol).LastWriteTime)
  Get-Content $pol -Tail 4 | ForEach-Object { $t = $_; if ($t.Length -gt 140) { $t = $t.Substring(0,140) }; Write-Output ('  ' + $t) }
} else { Write-Output '  NO_POLICY_LOG' }
Write-Output '=== 5. SMS_R_System client flag ==='
$d = Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_R_System -Filter "Name='MBR02'" -ErrorAction SilentlyContinue
if ($d) { $d | ForEach-Object { Write-Output ('  RESOURCE: ' + $_.ResourceID + ' | client=' + $_.Client + ' | ' + $_.Name) } }
Write-Output 'REG_CHECK_DONE'
