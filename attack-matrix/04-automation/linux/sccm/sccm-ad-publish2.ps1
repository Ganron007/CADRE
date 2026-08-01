# Query AD for CAD site MP object (retry with AD module + LDAP fallback) — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== Try Get-ADObject (ActiveDirectory module) ==='
try {
  Import-Module ActiveDirectory -ErrorAction Stop
  $objs = Get-ADObject -Server 'dc03.range.local' -LDAPFilter '(&(objectCategory=mSSMSManagementPoint)(mSSMSSiteCode=CAD))' -Properties mSSMSCertificate,mSSMSOperationalXML,mSSMSMPAddress,mSSMSVersion -ErrorAction Stop
  Write-Output ("  RESULTS=" + @($objs).Count)
  foreach ($o in $objs) {
    Write-Output ("  --- " + $o.DistinguishedName)
    Write-Output ("    mSSMSMPAddress=" + $o.mSSMSMPAddress)
    Write-Output ("    mSSMSVersion=" + $o.mSSMSVersion)
    if ($o.mSSMSCertificate) {
      try {
        $x = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(,[byte[]]$o.mSSMSCertificate)
        Write-Output ("    AD cert serial=" + $x.SerialNumber + " notbefore=" + $x.NotBefore)
      } catch { Write-Output ("    AD cert decode ERROR: " + $_.Exception.Message) }
    } else { Write-Output '    mSSMSCertificate: (none)' }
    if ($o.mSSMSOperationalXML) {
      $op = [string]$o.mSSMSOperationalXML
      if ($op -match 'SiteSigningCert>([0-9A-F]{40})') { Write-Output ("    OperationalXml SiteSigningCert prefix=" + $matches[1]) }
    }
  }
} catch { Write-Output ("  Get-ADObject ERROR: " + $_.Exception.Message) }

Write-Output '=== Fallback: raw LDAP via DirectoryEntry ==='
try {
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/DC=range,DC=local")
  $searcher = New-Object System.DirectoryServices.DirectorySearcher($root)
  $searcher.Filter = '(&(objectCategory=mSSMSManagementPoint)(mSSMSSiteCode=CAD))'
  $searcher.PropertiesToLoad.AddRange(@('mSSMSCertificate','mSSMSOperationalXML','mSSMSMPAddress','mSSMSVersion'))
  $res = $searcher.FindAll()
  Write-Output ("  RESULTS=" + $res.Count)
  foreach ($r in $res) {
    $p = $r.Properties
    Write-Output ("  --- MP ---")
    Write-Output ("    mSSMSMPAddress=" + $p['mssmsmpaddress'])
    if ($p['mssmscertificate']) {
      try {
        $x = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(,[byte[]]$p['mssmscertificate'][0])
        Write-Output ("    AD cert serial=" + $x.SerialNumber + " notbefore=" + $x.NotBefore)
      } catch { Write-Output ("    cert decode ERROR: " + $_.Exception.Message) }
    }
    if ($p['mssmsoperationalxml']) {
      $op = [string]$p['mssmsoperationalxml'][0]
      if ($op -match 'SiteSigningCert>([0-9A-F]{40})') { Write-Output ("    OperationalXml SiteSigningCert prefix=" + $matches[1]) }
    }
  }
} catch { Write-Output ("  LDAP ERROR: " + $_.Exception.Message) }
Write-Output 'ADCHECK2_DONE'
