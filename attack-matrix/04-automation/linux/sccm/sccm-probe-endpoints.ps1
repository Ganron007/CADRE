# Map AdminService endpoints as svc_sccm (explicit creds) from ws01
$ErrorActionPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertPolicy3 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint s, X509Certificate c, WebRequest r, int p) { return true; }
}
"@
[Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertPolicy3
$sec = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('RANGE\svc_sccm', $sec)
$urls = @(
  'https://mbr02.range.local/AdminService/v1.0/',
  'https://mbr02.range.local/AdminService/v1.0/SMS_Site',
  'https://mbr02.range.local/AdminService/wmi/SMS_Site',
  'https://mbr02.range.local/AdminService/v1.0/Device',
  'https://mbr02.range.local/AdminService/wmi/SMS_System'
)
foreach ($u in $urls) {
  try {
    $r = Invoke-WebRequest -Uri $u -Credential $cred -UseBasicParsing -Method Get -TimeoutSec 25
    $body = $r.Content
    if ($body.Length -gt 200) { $body = $body.Substring(0,200) }
    Write-Output ("OK  " + $u + " -> " + $r.StatusCode + " | " + $body)
  } catch {
    $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 'n/a' }
    Write-Output ("ERR " + $u + " -> " + $code)
  }
}
Write-Output 'PROBE_DONE'
