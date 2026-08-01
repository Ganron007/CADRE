# CONFIGURE AD publishing for site CAD — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== Step 1: Get forest + site definition ==='
try {
  $forest = Get-CMActiveDirectoryForest -ForestFqdn 'range.local' -ErrorAction Stop
  Write-Output ("  forest=" + $forest.ForestFQDN + " id=" + $forest.ForestID)
} catch { Write-Output ("  get forest ERROR: " + $_.Exception.Message); $forest = $null }

try {
  $sd = Get-CMSiteDefinition -SiteCode 'CAD' -ErrorAction Stop
  Write-Output ("  siteDef=" + $sd.SiteCode + " | " + $sd.SiteName)
} catch {
  Write-Output ("  Get-CMSiteDefinition -SiteCode ERROR: " + $_.Exception.Message)
  try { $sd = Get-CMSiteDefinition -ErrorAction Stop | Where-Object { $_.SiteCode -eq 'CAD' } | Select-Object -First 1; Write-Output ("  siteDef(fallback)=" + $sd.SiteCode) } catch { Write-Output ("  get sd fallback ERROR: " + $_.Exception.Message); $sd = $null }
}

Write-Output '=== Step 2: Set publishing path on forest + add site ==='
$pubPath = 'CN=System Management,CN=System,DC=range,DC=local'
try {
  if ($sd) {
    Set-CMActiveDirectoryForest -ForestFqdn 'range.local' -PublishingPath $pubPath -AddPublishingSite $sd -EnableDiscovery $true -PassThru -ErrorAction Stop | Out-Null
    Write-Output '  Set-CMActiveDirectoryForest OK'
  } else {
    Set-CMActiveDirectoryForest -ForestFqdn 'range.local' -PublishingPath $pubPath -EnableDiscovery $true -PassThru -ErrorAction Stop | Out-Null
    Write-Output '  Set-CMActiveDirectoryForest OK (no site def)'
  }
} catch { Write-Output ("  Set-CMActiveDirectoryForest ERROR: " + $_.Exception.Message) }

try {
  if ($forest) {
    Set-CMSite -SiteCode 'CAD' -AddActiveDirectoryForest $forest -PassThru -ErrorAction Stop | Out-Null
    Write-Output '  Set-CMSite AddActiveDirectoryForest OK'
  }
} catch { Write-Output ("  Set-CMSite ERROR: " + $_.Exception.Message) }

Write-Output '=== Step 3: Verify forest publishing config ==='
$f2 = Get-CMActiveDirectoryForest -ForestFqdn 'range.local' -ErrorAction SilentlyContinue
Write-Output ("  PublishingPath=" + $f2.PublishingPath)
Write-Output ("  PublishingStatus=" + $f2.PublishingStatus)

Write-Output '=== Step 4: Restart SMS_EXECUTIVE to trigger AD publish ==='
Restart-Service SMS_EXECUTIVE -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5
Get-Service SMS_EXECUTIVE -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  SMS_EXECUTIVE=" + $_.Status) }
Write-Output '  waiting 150s for AD publication...'
Start-Sleep -Seconds 150
Get-Service SMS_EXECUTIVE -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  SMS_EXECUTIVE(after)=" + $_.Status) }

Write-Output '=== Step 5: Verify AD now has full data ==='
try {
  $user = 'RANGE\svc_naa'; $pass = 'N@A_s3rv1c3!'
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/DC=range,DC=local", $user, $pass)
  $s = New-Object System.DirectoryServices.DirectorySearcher($root)
  $s.Filter = '(&(objectCategory=mSSMSManagementPoint)(mSSMSSiteCode=CAD))'
  $s.PropertiesToLoad.AddRange(@('mSSMSOperationalXML','mSSMSCertificate','mSSMSMPAddress'))
  $r = $s.FindOne()
  if ($r) {
    Write-Output ("  MP object found: " + $r.Properties['distinguishedname'])
    if ($r.Properties['mssmsoperationalxml']) {
      $op = [string]$r.Properties['mssmsoperationalxml'][0]
      Write-Output ("  OperationalXml len=" + $op.Length)
      if ($op -match 'SiteSigningCert>([0-9A-F]{40})') { Write-Output ("  AD SiteSigningCert prefix=" + $matches[1]) }
      if ($op -match 'SSLState" Value="([0-9]+)"') { Write-Output ("  AD SSLState=" + $matches[1]) }
    } else { Write-Output '  OperationalXml: STILL MISSING' }
    if ($r.Properties['mssmsmpaddress']) { Write-Output ("  MPAddress=" + $r.Properties['mssmsmpaddress']) } else { Write-Output '  MPAddress: missing' }
  } else { Write-Output '  MP object not found' }
} catch { Write-Output ("  AD verify ERROR: " + $_.Exception.Message) }
Write-Output 'ADPUBLISH_DONE'
