[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"
$url = "http://dc01.cadre.local/certsrv/"
try {
    $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
    Write-Output ("T052_OK: web enrollment reachable RC=" + $r.StatusCode)
    Write-Output ("T056_OK: web enrollment reachable RC=" + $r.StatusCode)
} catch {
    $msg = $_.Exception.Message
    Write-Output ("T052_INFO: " + $msg)
    if ($msg -match "401|Unauthorized") {
        Write-Output "T052_OK: web enrollment present (HTTP 401)"
        Write-Output "T056_OK: web enrollment present (HTTP 401)"
    } else { throw $msg }
}
