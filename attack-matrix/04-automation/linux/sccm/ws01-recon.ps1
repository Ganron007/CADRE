# ws01 recon for SCCM client install — analyst_t1 (CONFIG channel)
$ErrorActionPreference = 'Continue'
Write-Output '=== Identity ==='
Write-Output ("  whoami=" + (whoami))
Write-Output ("  hostname=" + $env:COMPUTERNAME)
Write-Output ("  Domain=" + (Get-CimInstance Win32_ComputerSystem).Domain)
Write-Output ("  PartOfDomain=" + (Get-CimInstance Win32_ComputerSystem).PartOfDomain)
Write-Output ("  OS=" + (Get-CimInstance Win32_OperatingSystem).Caption + " " + (Get-CimInstance Win32_OperatingSystem).Version)
$admin = (whoami /groups | Select-String 'S-1-5-32-544')
Write-Output ("  IsAdmin=" + [bool]$admin)
Write-Output ('  IsAdminRaw=' + ($admin -join ';'))

Write-Output '=== DNS resolution of mbr02.range.local ==='
try { Resolve-DnsName mbr02.range.local -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  " + $_.Name + " -> " + $_.IPAddress) } } catch { Write-Output ("  DNS error: " + $_.Exception.Message) }
Write-Output '=== MP reachability (HTTP 80 + HTTPS 443) ==='
foreach ($port in @(80,443)) {
  $t = Test-NetConnection 192.168.77.23 -Port $port -WarningAction SilentlyContinue
  Write-Output ("  mbr02:" + $port + " = " + $t.TcpTestSucceeded)
}
Write-Output '=== ccmsetup.cab over HTTP ==='
try {
  $r = Invoke-WebRequest -Uri 'http://mbr02.range.local/CCM_Client/ccmsetup.cab' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
  Write-Output ("  HTTP status=" + $r.StatusCode + " len=" + $r.RawContentLength)
} catch { Write-Output ("  HTTP error: " + $_.Exception.Message) }
try {
  $r2 = Invoke-WebRequest -Uri 'http://192.168.77.23/CCM_Client/ccmsetup.cab' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
  Write-Output ("  HTTP via IP status=" + $r2.StatusCode + " len=" + $r2.RawContentLength)
} catch { Write-Output ("  HTTP via IP error: " + $_.Exception.Message) }
Write-Output 'WS01_RECON_DONE'
