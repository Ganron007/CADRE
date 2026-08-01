# svc_sccm roles via AdminService REST (works for svc_sccm) — analyst_t1 (ws01)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy2 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy2

$mp = 'mbr02.range.local'
$svcUser = 'range\svc_sccm'
$svcPass = 's3rv1c3_SCCM!'
$sec = ConvertTo-SecureString $svcPass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($svcUser, $sec)

function Get-AS($path) {
  $u = "https://$mp/AdminService/v1.0/$path"
  try {
    $r = Invoke-WebRequest -Uri $u -Credential $cred -UseBasicParsing -TimeoutSec 30
    return $r.Content
  } catch {
    $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    return "ERROR $code : $($_.Exception.Message)"
  }
}

Write-Output '=== AdminService /wmi/SMS_Admin (svc_sccm entry) ==='
$admins = Get-AS "wmi/SMS_Admin"
Write-Output $admins.Substring(0, [Math]::Min(3000, $admins.Length))

Write-Output ''
Write-Output '=== AdminService /wmi/SMS_AdminRole (roles) ==='
$roles = Get-AS "wmi/SMS_AdminRole"
Write-Output $roles.Substring(0, [Math]::Min(4000, $roles.Length))
Write-Output 'ROLES3_DONE'
