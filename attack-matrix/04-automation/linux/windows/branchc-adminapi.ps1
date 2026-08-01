$ErrorActionPreference = "SilentlyContinue"
Add-Type -TypeDefinition @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls

$secpass = ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', $secpass)

Write-Output "=== AdminService /wmi/ via Invoke-RestMethod ==="
try {
    $r = Invoke-RestMethod -Uri "https://mbr02.range.local/AdminService/wmi/" -Credential $cred -Method Get -TimeoutSec 25 -ErrorAction Stop
    Write-Output "OK count=$($r.Count)"
    $r | Select-Object -First 50 | ForEach-Object { Write-Output "  $_" }
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
    if ($_.Exception.InnerException) { Write-Output "INNER: $($_.Exception.InnerException.Message)" }
    if ($_.ErrorDetails) { Write-Output "DETAILS: $($_.ErrorDetails.Message)" }
}
Write-Output "=== AdminService root ==="
try {
    $r2 = Invoke-RestMethod -Uri "https://mbr02.range.local/AdminService/" -Credential $cred -Method Get -TimeoutSec 25 -ErrorAction Stop
    Write-Output "OK root: $($r2 | Out-String -Width 250)"
} catch {
    Write-Output "FAIL: $($_.Exception.Message)"
}
Write-Output "DONE"
