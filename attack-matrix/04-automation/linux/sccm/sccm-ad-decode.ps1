# Decode AD mSSMSCapabilities SiteSigningCert + MP serviceBindingInformation — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$user = 'RANGE\svc_naa'; $pass = 'N@A_s3rv1c3!'

function Decode-Cert([string]$hex) {
  $clean = ($hex -replace '\s','')
  if ($clean.Length -lt 20) { return "TOO_SHORT" }
  try {
    $bytes = New-Object byte[] ($clean.Length / 2)
    for ($i=0; $i -lt $bytes.Length; $i++) { $bytes[$i] = [Convert]::ToByte($clean.Substring($i*2,2),16) }
    $x = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(,$bytes)
    return ("serial=" + $x.SerialNumber + " subj=" + $x.Subject + " notBefore=" + $x.NotBefore)
  } catch { return ("decode error: " + $_.Exception.Message) }
}

Write-Output '=== AD MP object mSSMSCapabilities ==='
try {
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/CN=SMS-MP-CAD-MBR02.RANGE.LOCAL,CN=System Management,CN=System,DC=range,DC=local", $user, $pass)
  $root.RefreshCache()
  $cap = [string]$root.Properties['mSSMSCapabilities'][0]
  Write-Output ("  len=" + $cap.Length)
  if ($cap -match 'SiteSigningCert>([0-9A-F]+)</') { Write-Output ("  SiteSigningCert -> " + (Decode-Cert $matches[1])) }
  if ($cap -match 'SSLState" Value="([0-9]+)"') { Write-Output ("  SSLState=" + $matches[1]) }
  if ($cap -match 'HTTPSPort>([0-9]+)</') { Write-Output ("  HTTPSPort=" + $matches[1]) }
  if ($cap -match 'HTTPPort>([0-9]+)</') { Write-Output ("  HTTPPort=" + $matches[1]) }
  # print a readable snippet
  Write-Output ("  snippet: " + $cap.Substring(0, [Math]::Min(400, $cap.Length)))
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== AD MP object serviceBindingInformation (MP cert) ==='
try {
  $root2 = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/CN=SMS-MP-CAD-MBR02.RANGE.LOCAL,CN=System Management,CN=System,DC=range,DC=local", $user, $pass)
  $root2.RefreshCache()
  $sbi = [string]$root2.Properties['serviceBindingInformation'][0]
  Write-Output ("  len=" + $sbi.Length)
  Write-Output ("  MP cert -> " + (Decode-Cert $sbi))
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== AD Site object serviceBindingInformation (root key) ==='
try {
  $root3 = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/CN=SMS-Site-CAD,CN=System Management,CN=System,DC=range,DC=local", $user, $pass)
  $root3.RefreshCache()
  $sbi3 = [string]$root3.Properties['serviceBindingInformation'][0]
  Write-Output ("  len=" + $sbi3.Length)
  Write-Output ("  prefix=" + $sbi3.Substring(0, [Math]::Min(80, $sbi3.Length)))
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }
Write-Output 'DECODE_DONE'
