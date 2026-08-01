# WT039 prep: find Script actions in AdminService metadata + SMS_Scripts class — analyst_t1 (ws01)
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy10 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy10
$mp = 'mbr02.range.local'
$cred = New-Object System.Management.Automation.PSCredential('range\svc_sccm', (ConvertTo-SecureString 's3rv1c3_SCCM!' -AsPlainText -Force))

Write-Output '=== [1] AdminService metadata: Script-related EntityTypes ==='
$md = (Invoke-WebRequest -Uri "https://$mp/AdminService/v1.0/`$metadata" -Credential $cred -UseBasicParsing -TimeoutSec 30).Content
[regex]::Matches($md, '<EntityType Name="([^"]*[Ss]cript[^"]*)"') | ForEach-Object { Write-Output ("  ET: " + $_.Groups[1].Value) }
Write-Output '=== [2] Script-related Actions/Functions ==='
[regex]::Matches($md, '<(Action|Function) Name="([^"]*[Ss]cript[^"]*)"[^>]*>') | ForEach-Object { Write-Output ("  " + $_.Groups[1].Value + ": " + $_.Groups[2].Value) }
Write-Output '=== [3] Script entity set names ==='
[regex]::Matches($md, '<EntitySet Name="([^"]*[Ss]cript[^"]*)"') | ForEach-Object { Write-Output ("  ES: " + $_.Groups[1].Value) }
Write-Output '=== [4] SMS_Scripts via WMI as MBR02\vagrant: methods ==='
$cred2 = New-Object System.Management.Automation.PSCredential('MBR02\vagrant', (ConvertTo-SecureString 'vagrant' -AsPlainText -Force))
try {
  $mc = New-Object System.Management.ManagementClass("\\$mp\root\SMS\site_CAD:SMS_Scripts")
  # can't set creds on ManagementClass easily; use Get-WmiObject to test readability
  $s = Get-WmiObject -ComputerName $mp -Credential $cred2 -Namespace root\SMS\site_CAD -Class SMS_Scripts -ErrorAction Stop | Select-Object -First 5
  Write-Output ("SMS_Scripts readable, rows=" + @($s).Count)
  foreach ($x in $s | Select-Object -First 3) { Write-Output ("  ScriptGuid=" + $x.ScriptGuid + " Name=" + $x.ScriptName + " ApprovalState=" + $x.ApprovalState) }
} catch { Write-Output ("WMI ERR: " + $_.Exception.Message) }
Write-Output 'SCRIPT_PREP_DONE'
