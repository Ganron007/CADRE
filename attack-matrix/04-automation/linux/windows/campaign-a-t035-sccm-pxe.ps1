[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"
$mbr02 = "192.168.77.23"
Write-Output ("T035_MBR02_PING=" + (Test-Connection $mbr02 -Count 1 -Quiet))
$tnc = Test-NetConnection $mbr02 -Port 80 -WarningAction SilentlyContinue
Write-Output ("T035_MBR02_HTTP=" + $tnc.TcpTestSucceeded)
try {
    $r = Invoke-WebRequest -Uri ("http://" + $mbr02 + "/SMS_MP/.sms_aut?MPLIST") -UseBasicParsing -TimeoutSec 8
    Write-Output ("T035_MPLIST=" + [int]$r.StatusCode)
} catch { Write-Output ("T035_MPLIST=" + $_.Exception.Message) }
$ccm = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\CCM" -ErrorAction SilentlyContinue
if ($ccm) { Write-Output "T035_CCM_CLIENT=present" }
Write-Output "T035_OK: PXE/MP surface check from ws01 (not a PXE client boot)"
