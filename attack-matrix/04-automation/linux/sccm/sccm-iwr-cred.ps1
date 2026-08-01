# Test AdminService auth as svc_sccm via explicit NTLM/Negotiate creds from ws01
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertPolicy2 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint s, X509Certificate c, WebRequest r, int p) { return true; }
}
"@
[Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertPolicy2
$sec = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('RANGE\svc_sccm', $sec)
try {
    $r = Invoke-WebRequest -Uri 'https://mbr02.range.local/AdminService/wmi/SMS_Site' -Credential $cred -UseBasicParsing -Method Get -TimeoutSec 30
    Write-Output ("IWR_CRED_STATUS=" + $r.StatusCode)
    Write-Output ("IWR_CRED_BODY=" + $r.Content.Substring(0, [Math]::Min(400, $r.Content.Length)))
} catch {
    Write-Output ("IWR_CRED_ERR=" + $_.Exception.Message)
    if ($_.Exception.Response) { Write-Output ("IWR_CRED_HTTP=" + [int]$_.Exception.Response.StatusCode) }
}
Write-Output 'IWR_CRED_DONE'
