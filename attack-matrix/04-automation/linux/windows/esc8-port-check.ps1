# Verify dc01 web enrollment ports from ws01
$ErrorActionPreference = "Continue"
Write-Output "=== TCP 80/443 to dc01 (192.168.77.10) ==="
foreach ($p in 80,443) {
  $t = Test-NetConnection -ComputerName 192.168.77.10 -Port $p -WarningAction SilentlyContinue
  Write-Output "port $p : $($t.TcpTestSucceeded)"
}
Write-Output "=== HTTP vs HTTPS certsrv ==="
try {
  $r = Invoke-WebRequest -Uri "http://192.168.77.10/certsrv/" -UseBasicParsing -TimeoutSec 6 -UseDefaultCredentials
  Write-Output "HTTP_OK $($r.StatusCode)"
} catch {
  Write-Output "HTTP_ERR $($_.Exception.Response.StatusCode.value__) $($_.Exception.Message)"
}
try {
  $r = Invoke-WebRequest -Uri "https://192.168.77.10/certsrv/" -UseBasicParsing -TimeoutSec 6 -SkipCertificateCheck -UseDefaultCredentials
  Write-Output "HTTPS_OK $($r.StatusCode)"
} catch {
  Write-Output "HTTPS_ERR $($_.Exception.Response.StatusCode.value__) $($_.Exception.Message)"
}
