# Query AD with explicit domain creds (svc_naa, DA) — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$user = 'RANGE\svc_naa'
$pass = 'N@A_s3rv1c3!'

Write-Output '=== LDAP query for mSSMSManagementPoint site CAD (with creds) ==='
try {
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/DC=range,DC=local", $user, $pass)
  $searcher = New-Object System.DirectoryServices.DirectorySearcher($root)
  $searcher.Filter = '(&(objectCategory=mSSMSManagementPoint)(mSSMSSiteCode=CAD))'
  $searcher.PropertiesToLoad.AddRange(@('mSSMSCertificate','mSSMSOperationalXML','mSSMSMPAddress','mSSMSVersion','mSSMSDefaultMP'))
  $res = $searcher.FindAll()
  Write-Output ("  RESULTS=" + $res.Count)
  foreach ($r in $res) {
    $p = $r.Properties
    Write-Output ("  --- MP object ---")
    Write-Output ("    mSSMSMPAddress=" + $p['mssmsmpaddress'])
    Write-Output ("    mSSMSVersion=" + $p['mssmsversion'])
    Write-Output ("    mSSMSDefaultMP=" + $p['mssmsdefaultmp'])
    if ($p['mssmscertificate']) {
      try {
        $x = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(,[byte[]]$p['mssmscertificate'][0])
        Write-Output ("    AD mSSMSCertificate serial=" + $x.SerialNumber + " notbefore=" + $x.NotBefore + " subject=" + $x.Subject)
      } catch { Write-Output ("    cert decode ERROR: " + $_.Exception.Message) }
    } else { Write-Output '    mSSMSCertificate: (none)' }
    if ($p['mssmsoperationalxml']) {
      $op = [string]$p['mssmsoperationalxml'][0]
      if ($op -match 'SiteSigningCert>([0-9A-F]{40})') { Write-Output ("    OperationalXml SiteSigningCert prefix=" + $matches[1]) }
    } else { Write-Output '    mSSMSOperationalXML: (none)' }
  }
} catch { Write-Output ("  LDAP ERROR: " + $_.Exception.Message) }

Write-Output '=== Also search System Management container for SMS-Site-CAD objects ==='
try {
  $root2 = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/CN=System Management,CN=System,DC=range,DC=local", $user, $pass)
  $searcher2 = New-Object System.DirectoryServices.DirectorySearcher($root2)
  $searcher2.Filter = '(objectClass=*)'
  $searcher2.SizeLimit = 50
  $res2 = $searcher2.FindAll()
  Write-Output ("  RESULTS=" + $res2.Count)
  foreach ($r in $res2) { Write-Output ("    " + $r.Properties['distinguishedname']) }
} catch { Write-Output ("  System Management query ERROR: " + $_.Exception.Message) }
Write-Output 'ADCHECK3_DONE'
