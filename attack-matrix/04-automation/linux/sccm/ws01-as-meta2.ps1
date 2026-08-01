# AdminService: full function defs + GetGrantedClassPermissions — analyst_t1 (ws01)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy5 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy5

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
    return "OK " + $r.StatusCode + " :: " + $r.Content.Substring(0, [Math]::Min(1500, $r.Content.Length))
  } catch {
    $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    return "ERROR $code : " + $_.Exception.Message
  }
}

Write-Output '=== 1. GetGrantedClassPermissions (as svc_sccm) ==='
Write-Output (Get-AS 'AdminService.GetGrantedClassPermissions')
Write-Output ''
Write-Output '=== 2. Try bound: Device/AdminService.GetGrantedClassPermissions ==='
Write-Output (Get-AS 'Device/AdminService.GetGrantedClassPermissions')
Write-Output ''
Write-Output '=== 3. ListCMPivotEntity (allowed entities for this user) ==='
Write-Output (Get-AS 'AdminService.ListCMPivotEntity')
Write-Output ''
Write-Output '=== 4. Search metadata for RunCMPivot / RunScript / GetGrantedClassPermissions defs ==='
$md = (Invoke-WebRequest -Uri "https://$mp/AdminService/v1.0/`$metadata" -Credential $cred -UseBasicParsing -TimeoutSec 30).Content
foreach ($needle in @('RunCMPivot','RunScript','GetGrantedClassPermissions','ListCMPivotEntity','CMPivotScript','InitiateClientOperation')) {
  $i = $md.IndexOf($needle)
  if ($i -ge 0) {
    $start = [Math]::Max(0, $i - 300)
    $len = [Math]::Min(700, $md.Length - $start)
    Write-Output ("--- $needle ---")
    Write-Output $md.Substring($start, $len)
    Write-Output ''
  } else {
    Write-Output ("--- $needle : NOT FOUND in metadata ---")
  }
}
Write-Output 'META2_DONE'
