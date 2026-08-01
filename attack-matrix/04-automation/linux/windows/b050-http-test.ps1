# Test web enrollment endpoints from ws01
$ErrorActionPreference = "Continue"
$tests = @(
  "http://dc01.cadre.local/certsrv/certfnsh.asp",
  "http://192.168.77.10/certsrv/certfnsh.asp",
  "http://dc01.cadre.local/",
  "https://dc01.cadre.local/certsrv/certfnsh.asp"
)
foreach ($t in $tests) {
  try {
    $code = curl.exe -s -o NUL -w "%{http_code}" --connect-timeout 5 $t
    Write-Output "$t => HTTP $code"
  } catch {
    Write-Output "$t => ERROR $($_.Exception.Message)"
  }
}
# Also: what's listening on dc01:80? (from ws01)
Write-Output "=== certsrv browse from ws01 ==="
try {
  $r = Invoke-WebRequest -Uri "http://dc01.cadre.local/certsrv/" -UseBasicParsing -TimeoutSec 8 -ErrorAction Stop
  Write-Output "certsrv_root_status=$($r.StatusCode)"
} catch {
  Write-Output "certsrv_root_err=$($_.Exception.Message)"
}
Write-Output "=== TEST_DONE ==="
