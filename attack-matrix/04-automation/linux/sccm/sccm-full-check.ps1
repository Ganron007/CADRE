# Full client + device record check — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Write-Output '=== Waiting 5 min for client policy/assignment ==='
Start-Sleep -Seconds 300
Write-Output '=== 1. root\ccm client ==='
try {
  $c = Get-CimInstance -Namespace root\CCM -ClassName SMS_Client -ErrorAction Stop
  Write-Output ('  CLIENT_VER=' + $c.ClientVersion + ' | Site=' + $c.SiteCode + ' | Assigned=' + $c.AssignedSiteCode + ' | MP=' + $c.AssignedMP)
} catch { Write-Output ('  ROOTCCM_ERR=' + $_.Exception.Message) }
Write-Output '=== 2. CCM registry ==='
$r = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\CCM' -ErrorAction SilentlyContinue
if ($r) { Write-Output ('  SITE=' + $r.AssignedSiteCode + ' | MP=' + $r.MP + ' | VER=' + $r.SMSClientVersion) } else { Write-Output '  REG=MISSING' }
Write-Output '=== 3. CCM folder + service ==='
Write-Output ('  CCM_DIR=' + (Test-Path 'C:\Windows\CCM'))
Write-Output ('  CCMEXEC=' + (Get-Service CcmExec -ErrorAction SilentlyContinue).Status)
Write-Output '=== 4. Device record (SMS_R_System) ==='
try {
  $d = Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_R_System -Filter "Name='MBR02'" -ErrorAction SilentlyContinue
  if ($d) { $d | ForEach-Object { Write-Output ('  RESOURCE: ' + $_.ResourceID + ' | ' + $_.Name + ' | client=' + $_.Client + ' | ver=' + $_.ClientVersion) } }
  else {
    $all = Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_R_System -ErrorAction SilentlyContinue
    Write-Output ('  NO_MBR02_ROW; total SMS_R_System=' + @($all).Count)
    $all | Select-Object -First 5 | ForEach-Object { Write-Output ('    ROW: ' + $_.ResourceID + ' | ' + $_.Name) }
  }
} catch { Write-Output ('  R_ERR=' + $_.Exception.Message) }
Write-Output '=== 5. Client log last ==='
Get-Content 'C:\Windows\CCMSetup\Logs\ccmsetup.log' -Tail 3 -ErrorAction SilentlyContinue | ForEach-Object { $t = $_; if ($t.Length -gt 140) { $t = $t.Substring(0,140) }; Write-Output ('  ' + $t) }
Write-Output 'FULL_CHECK_DONE'
