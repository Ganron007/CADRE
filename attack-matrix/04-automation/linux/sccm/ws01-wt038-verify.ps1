# After reboot: trigger policy update + verify WT038 on client
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy22 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy22
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', (ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))
$base = 'https://mbr02.range.local/AdminService'

function Invoke-AS($method, $path, $bodyJson) {
  try {
    if ($bodyJson) { $r = Invoke-RestMethod -Uri "$base/$path" -Method $method -Body $bodyJson -ContentType 'application/json' -Credential $cred -TimeoutSec 30 }
    else { $r = Invoke-RestMethod -Uri "$base/$path" -Method $method -Credential $cred -TimeoutSec 30 }
    return @{ ok = $true; data = $r }
  } catch {
    $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    return @{ ok = $false; code = $code; detail = $_.ErrorDetails.Message }
  }
}

# Trigger machine policy retrieval on CAD00016
Write-Output 'Triggering machine policy retrieval (Type=8)...'
$body = @{ Type = 8; TargetCollectionID = 'CAD00016' } | ConvertTo-Json
$r = Invoke-AS 'POST' 'wmi/SMS_ClientOperation.InitiateClientOperation' $body
if ($r.ok) { Write-Output ("  op=" + $r.data.OperationID) } else { Write-Output ("  FAIL " + $r.code + " : " + $r.detail) }

Write-Output 'Waiting 120s for client to process...'
Start-Sleep -Seconds 120

$p1 = 'C:\Windows\Temp\wt038-system.txt'
$p2 = 'C:\Windows\Temp\wt038-marker.txt'
Write-Output ("markers sys=" + (Test-Path $p1) + " marker=" + (Test-Path $p2))
if (Test-Path $p1) { Write-Output '--- wt038-system.txt ---'; Get-Content $p1 }
if (Test-Path $p2) { Write-Output '--- wt038-marker.txt ---'; Get-Content $p2 }

Write-Output '--- CCM_Application (client SDK) ---'
Get-WmiObject -Namespace root\ccm\clientsdk -Class CCM_Application -ErrorAction SilentlyContinue | Select-Object Name, Id, AppDTId | Format-List

Write-Output '--- PolicyAgent.log tail ---'
if (Test-Path 'C:\Windows\CCM\Logs\PolicyAgent.log') { Get-Content 'C:\Windows\CCM\Logs\PolicyAgent.log' -Tail 15 }

Write-Output '--- AppEnforce.log tail ---'
if (Test-Path 'C:\Windows\CCM\Logs\AppEnforce.log') { Get-Content 'C:\Windows\CCM\Logs\AppEnforce.log' -Tail 20 }
