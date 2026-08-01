# Get working CMPivot script properties to mirror for CreateScripts — analyst_t1 (ws01)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy13 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy13
$mp = 'mbr02.range.local'
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', (ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))
$r = Invoke-RestMethod -Uri "https://$mp/AdminService/v1.0/Script('7DC6B6F1-E7F6-43C1-96E0-E1D16BC25C14')" -Credential $cred -TimeoutSec 30
$r | ConvertTo-Json -Depth 4
Write-Output 'CMPIVOT_SCRIPT_DONE'
