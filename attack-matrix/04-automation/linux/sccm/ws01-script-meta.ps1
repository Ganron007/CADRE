# Extract Script entity schema + RunScript/ScriptResult + approval from metadata — analyst_t1 (ws01)
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy11 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy11
$mp = 'mbr02.range.local'
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', (ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))
$md = (Invoke-WebRequest -Uri "https://$mp/AdminService/v1.0/`$metadata" -Credential $cred -UseBasicParsing -TimeoutSec 30).Content

Write-Output '=== Script EntityType definition ==='
$i = $md.IndexOf('<EntityType Name="Script"')
if ($i -ge 0) {
  $chunk = $md.Substring($i, [Math]::Min(2500, $md.Length - $i))
  $end = $chunk.IndexOf('</EntityType>')
  Write-Output $chunk.Substring(0, $end + 13)
} else { Write-Output 'not found' }

Write-Output ''
Write-Output '=== RunScript action ==='
$i = $md.IndexOf('<Action Name="RunScript"')
if ($i -ge 0) { Write-Output $md.Substring($i, [Math]::Min(700, $md.Length - $i)) } else { Write-Output 'not found' }

Write-Output ''
Write-Output '=== ScriptResult function ==='
$i = $md.IndexOf('<Function Name="ScriptResult"')
if ($i -ge 0) { Write-Output $md.Substring($i, [Math]::Min(700, $md.Length - $i)) } else { Write-Output 'not found' }

Write-Output ''
Write-Output '=== Approve-related ==='
[regex]::Matches($md, '<(Action|Function) Name="([^"]*[Aa]pprov[^"]*)"') | ForEach-Object { Write-Output ("  " + $_.Groups[1].Value + ": " + $_.Groups[2].Value) }
Write-Output 'META_SCRIPT_DONE'
