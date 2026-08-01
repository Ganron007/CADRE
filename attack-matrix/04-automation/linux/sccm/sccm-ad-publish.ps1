# Query AD for current CAD site MP OperationalXml + compare signing cert serial — CONFIG, vagrant
$ErrorActionPreference = 'Continue'

Write-Output '=== ADSI query: mSSMSManagementPoint for site CAD ==='
$searcher = New-Object System.DirectoryServices.DirectorySearcher([adsi]"LDAP://dc03.range.local/DC=range,DC=local")
$searcher.Filter = '(&(ObjectCategory=mSSMSManagementPoint)(mSSMSSiteCode=CAD))'
$searcher.PropertiesToLoad.AddRange(@('name','mSSMSDefaultMP','mSSMSMPAddress','mSSMSSiteCode','mSSMSVersion','mSSMSCertificate','mSSMSOperationalXML'))
try {
  $results = $searcher.FindAll()
  Write-Output ("  RESULTS=" + $results.Count)
  foreach ($r in $results) {
    $p = $r.Properties
    Write-Output ("  --- MP object ---")
    Write-Output ("    name=" + $p['name'])
    Write-Output ("    mSSMSDefaultMP=" + $p['mssmsdefaultmp'])
    Write-Output ("    mSSMSMPAddress=" + $p['mssmsmpaddress'])
    Write-Output ("    mSSMSVersion=" + $p['mssmsversion'])
    $cert = $p['mssmscertificate']
    if ($cert) {
      Write-Output ("    mSSMSCertificate len=" + $cert[0].Length)
      # try to decode the cert to get serial
      try {
        $bytes = [byte[]]$cert[0]
        $x = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(,$bytes)
        Write-Output ("    cert serial=" + $x.SerialNumber + " subject=" + $x.Subject + " notbefore=" + $x.NotBefore)
      } catch { Write-Output ("    cert decode ERROR: " + $_.Exception.Message) }
    } else { Write-Output '    mSSMSCertificate: (none)' }
    $op = $p['mssmsoperationalxml']
    if ($op) {
      Write-Output ("    mSSMSOperationalXML len=" + $op[0].Length)
      # extract the SiteSigningCert serial from OperationalXml
      if ($op[0] -match 'SiteSigningCert>(.{80})') { Write-Output ("    SiteSigningCert hex prefix=" + $matches[1]) }
    }
  }
} catch { Write-Output ("  AD query ERROR: " + $_.Exception.Message) }

Write-Output '=== Compare: site current SiteSigningCertificate (SMS\Security) serial ==='
$sec = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\SMS\Security' -ErrorAction SilentlyContinue
if ($sec.SiteSigningCertificate) {
  try {
    $hex = $sec.SiteSigningCertificate
    $clean = ($hex -replace '\s','')
    $bytes = New-Object byte[] ($clean.Length / 2)
    for ($i=0; $i -lt $bytes.Length; $i++) { $bytes[$i] = [Convert]::ToByte($clean.Substring($i*2,2),16) }
    $x = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(,$bytes)
    Write-Output ("  site SiteSigningCertificate serial=" + $x.SerialNumber + " subject=" + $x.Subject + " notbefore=" + $x.NotBefore)
  } catch { Write-Output ("  decode ERROR: " + $_.Exception.Message) }
} else { Write-Output '  no SiteSigningCertificate value' }
Write-Output 'ADCHECK_DONE'
