# Check SCCM AD publishing config via console module + container ACL — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== Load ConfigurationManager module ==='
$mod = 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
if (Test-Path $mod) {
  Import-Module $mod -ErrorAction SilentlyContinue
  Set-Location 'CAD:' -ErrorAction SilentlyContinue
  Write-Output '  module loaded, location set'
} else { Write-Output '  MODULE NOT FOUND' }

Write-Output '=== Get-CMSite (AD publishing settings) ==='
try {
  $site = Get-CMSite -SiteCode CAD -ErrorAction Stop
  Write-Output ("  SiteCode=" + $site.SiteCode)
  Write-Output ("  SiteName=" + $site.SiteName)
  Write-Output ("  ADForestName=" + $site.ADForestName)
  Write-Output ("  ADDomainName=" + $site.ADDomainName)
  Write-Output ("  ADSettings=" + $site.ADSettings)
  Write-Output ("  ADSiteCode=" + $site.ADSiteCode)
  Write-Output ("  Publish to AD? See ADSettings:")
  $site | Format-List * | Out-String -Width 200 | ForEach-Object { $_.Split("`n") | Where-Object { $_ -match 'AD|Publish|Forest|Domain|Site' } | ForEach-Object { Write-Output ("    " + $_.Trim()) } }
} catch { Write-Output ("  Get-CMSite ERROR: " + $_.Exception.Message) }

Write-Output '=== SMS_AD_UPDATE_COMPONENT interval (site control) ==='
try {
  $comp = Get-WmiObject -Namespace root\SMS\site_CAD -Query "SELECT * FROM SMS_SCI_Component WHERE ComponentName='SMS_AD_UPDATE_COMPONENT' AND SiteCode='CAD'" -ErrorAction SilentlyContinue
  if ($comp) {
    Write-Output ("  ComponentName=" + $comp.ComponentName)
    Write-Output ("  Interval=" + $comp.Props | Out-String)
  } else { Write-Output '  (component not found via raw WMI)' }
} catch { Write-Output ("  comp ERROR: " + $_.Exception.Message) }

Write-Output '=== System Management container ACL (mbr02$ write?) ==='
try {
  $user = 'RANGE\svc_naa'; $pass = 'N@A_s3rv1c3!'
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/CN=System Management,CN=System,DC=range,DC=local", $user, $pass)
  $root.RefreshCache()
  $acl = $root.ObjectSecurity
  $owner = $acl.Owner
  Write-Output ("  Owner=" + $owner)
  $acl.Access | ForEach-Object {
    $id = $_.IdentityReference.Value
    if ($id -match 'MBR02|SMS|RANGE') {
      Write-Output ("  ACE: " + $id + " | " + $_.AccessControlType + " | " + $_.ActiveDirectoryRights)
    }
  }
} catch { Write-Output ("  ACL ERROR: " + $_.Exception.Message) }
Write-Output 'ADCFG_DONE'
