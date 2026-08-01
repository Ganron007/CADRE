# Set SMS_ADForest.PublishingPath via WMI directly + restart + verify AD — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== Set PublishingPath via SMS provider WMI ==='
try {
  $forest = Get-WmiObject -Namespace root\SMS\site_CAD -Class SMS_ADForest -ErrorAction Stop | Where-Object { $_.ForestFQDN -eq 'range.local' }
  if ($forest) {
    Write-Output ("  before: PublishingPath='" + $forest.PublishingPath + "' Status=" + $forest.PublishingStatus)
    $forest.PublishingPath = 'CN=System Management,CN=System,DC=range,DC=local'
    $forest.Put() | Out-Null
    Write-Output '  Put() OK'
  } else { Write-Output '  forest not found' }
} catch { Write-Output ("  WMI set ERROR: " + $_.Exception.Message) }

# verify via cmdlet
try {
  $f = Get-CMActiveDirectoryForest -ForestFqdn 'range.local' -ErrorAction SilentlyContinue
  Write-Output ("  after: PublishingPath='" + $f.PublishingPath + "' Status=" + $f.PublishingStatus)
} catch { Write-Output ("  verify ERROR: " + $_.Exception.Message) }

Write-Output '=== Restart SMS_EXECUTIVE to trigger publish ==='
Restart-Service SMS_EXECUTIVE -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5
Get-Service SMS_EXECUTIVE -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  SMS_EXECUTIVE=" + $_.Status) }
Write-Output '  waiting 180s...'
Start-Sleep -Seconds 180

Write-Output '=== Verify forest + AD publication ==='
$f2 = Get-CMActiveDirectoryForest -ForestFqdn 'range.local' -ErrorAction SilentlyContinue
Write-Output ("  PublishingPath='" + $f2.PublishingPath + "' Status=" + $f2.PublishingStatus)
try {
  $user = 'RANGE\svc_naa'; $pass = 'N@A_s3rv1c3!'
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/DC=range,DC=local", $user, $pass)
  $s = New-Object System.DirectoryServices.DirectorySearcher($root)
  $s.Filter = '(&(objectCategory=mSSMSManagementPoint)(mSSMSSiteCode=CAD))'
  $s.PropertiesToLoad.AddRange(@('mSSMSOperationalXML','mSSMSCertificate','mSSMSMPAddress'))
  $r = $s.FindOne()
  if ($r) {
    if ($r.Properties['mssmsoperationalxml']) {
      $op = [string]$r.Properties['mssmsoperationalxml'][0]
      Write-Output ("  OperationalXml len=" + $op.Length)
      if ($op -match 'SiteSigningCert>([0-9A-F]{40})') { Write-Output ("  AD SiteSigningCert prefix=" + $matches[1]) }
    } else { Write-Output '  OperationalXml: STILL MISSING' }
    if ($r.Properties['mssmsmpaddress']) { Write-Output ("  MPAddress=" + $r.Properties['mssmsmpaddress']) } else { Write-Output '  MPAddress: still missing' }
  }
} catch { Write-Output ("  AD verify ERROR: " + $_.Exception.Message) }
Write-Output 'WMIPUB_DONE'
