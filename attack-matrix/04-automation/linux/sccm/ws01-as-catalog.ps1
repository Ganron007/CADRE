# AdminService $metadata + read tests — analyst_t1 (ws01)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy3 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy3

$mp = 'mbr02.range.local'
$svcUser = 'range\svc_sccm'
$svcPass = 's3rv1c3_SCCM!'
$sec = ConvertTo-SecureString $svcPass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($svcUser, $sec)

function Get-AS($path, $method='GET') {
  $u = "https://$mp/AdminService/v1.0/$path"
  try {
    if ($method -eq 'GET') { $r = Invoke-WebRequest -Uri $u -Credential $cred -UseBasicParsing -TimeoutSec 30 }
    else { $r = Invoke-WebRequest -Uri $u -Method $method -Credential $cred -UseBasicParsing -TimeoutSec 30 }
    return "OK " + $r.StatusCode + " len=" + $r.Content.Length + " :: " + $r.Content.Substring(0, [Math]::Min(1200, $r.Content.Length))
  } catch {
    $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    return "ERROR $code : " + $_.Exception.Message
  }
}

Write-Output '=== 1. /wmi/SMS_Site (read test) ==='
Write-Output (Get-AS 'wmi/SMS_Site')
Write-Output ''
Write-Output '=== 2. Device entity (read test, first 3) ==='
Write-Output (Get-AS 'Device?$top=3')
Write-Output ''
Write-Output '=== 3. $metadata (catalog) ==='
$md = Get-AS '$metadata'
Write-Output ($md.Substring(0, [Math]::Min(3000, $md.Length)))
Write-Output 'CATALOG_DONE'
