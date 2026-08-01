# Restart SMS_EXECUTIVE (force AD re-publication), wait, re-check AD cert — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== Before: AD-published OperationalXml cert prefix (client-visible) ==='
$user = 'RANGE\svc_naa'; $pass = 'N@A_s3rv1c3!'
try {
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/DC=range,DC=local", $user, $pass)
  $s = New-Object System.DirectoryServices.DirectorySearcher($root)
  $s.Filter = '(&(objectCategory=mSSMSManagementPoint)(mSSMSSiteCode=CAD))'
  $s.PropertiesToLoad.AddRange(@('mSSMSOperationalXML'))
  $r = $s.FindOne()
  if ($r -and $r.Properties['mssmsoperationalxml']) {
    $op = [string]$r.Properties['mssmsoperationalxml'][0]
    if ($op -match 'SiteSigningCert>([0-9A-F]{40})') { Write-Output ("  AD cert prefix=" + $matches[1]) }
    if ($op -match 'SSLState" Value="([0-9]+)"') { Write-Output ("  AD SSLState=" + $matches[1]) }
  } else { Write-Output '  (no OperationalXml on MP object)' }
} catch { Write-Output ("  AD query ERROR: " + $_.Exception.Message) }

Write-Output '=== Restart SMS_EXECUTIVE ==='
Restart-Service SMS_EXECUTIVE -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5
Get-Service SMS_EXECUTIVE -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  SMS_EXECUTIVE=" + $_.Status) }
Write-Output '  waiting 120s for components + AD publish...'
Start-Sleep -Seconds 120
Get-Service SMS_EXECUTIVE -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  SMS_EXECUTIVE(after wait)=" + $_.Status) }

Write-Output '=== After: AD-published cert ==='
try {
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/DC=range,DC=local", $user, $pass)
  $s = New-Object System.DirectoryServices.DirectorySearcher($root)
  $s.Filter = '(&(objectCategory=mSSMSManagementPoint)(mSSMSSiteCode=CAD))'
  $s.PropertiesToLoad.AddRange(@('mSSMSOperationalXML'))
  $r = $s.FindOne()
  if ($r -and $r.Properties['mssmsoperationalxml']) {
    $op = [string]$r.Properties['mssmsoperationalxml'][0]
    if ($op -match 'SiteSigningCert>([0-9A-F]{40})') { Write-Output ("  AD cert prefix=" + $matches[1]) }
  } else { Write-Output '  (no OperationalXml)' }
} catch { Write-Output ("  AD query ERROR: " + $_.Exception.Message) }
Write-Output 'ADPUBFORCE_DONE'
