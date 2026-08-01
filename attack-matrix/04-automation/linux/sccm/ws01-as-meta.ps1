# AdminService deep: metadata functions + direct device get — analyst_t1 (ws01)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy4 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy4

$mp = 'mbr02.range.local'
$svcUser = 'range\svc_sccm'
$svcPass = 's3rv1c3_SCCM!'
$sec = ConvertTo-SecureString $svcPass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($svcUser, $sec)

function Get-AS($path) {
  $u = "https://$mp/AdminService/v1.0/$path"
  try {
    $r = Invoke-WebRequest -Uri $u -Credential $cred -UseBasicParsing -TimeoutSec 30
    return "OK " + $r.StatusCode + " :: " + $r.Content.Substring(0, [Math]::Min(900, $r.Content.Length))
  } catch {
    $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    return "ERROR $code : " + $_.Exception.Message
  }
}

Write-Output '=== 1. Device(16777219) direct ==='
Write-Output (Get-AS 'Device(16777219)')
Write-Output ''
Write-Output '=== 2. Device?$top=5 with select ==='
Write-Output (Get-AS 'Device?$select=ResourceID,Name&$top=5')
Write-Output ''
Write-Output '=== 3. Collection entity ==='
Write-Output (Get-AS 'Collection?$top=5')
Write-Output ''
Write-Output '=== 4. $metadata: function imports (CMPivot/RunScript/Initiate) ==='
$md = (Invoke-WebRequest -Uri "https://$mp/AdminService/v1.0/`$metadata" -Credential $cred -UseBasicParsing -TimeoutSec 30).Content
$regex = [regex]'<FunctionImport Name="([^"]+)"[^>]*>'
$m = $regex.Matches($md)
foreach ($x in $m) { Write-Output ("  FI: " + $x.Groups[1].Value) }
$regex2 = [regex]'<Function Name="([^"]+)"'
$m2 = $regex2.Matches($md) | Select-Object -Unique
foreach ($x in $m2) { Write-Output ("  FN: " + $x.Groups[1].Value) }
Write-Output 'META_DONE'
