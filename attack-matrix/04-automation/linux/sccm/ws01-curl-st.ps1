# Test ST via curl --negotiate (explicit SSPI Kerberos) — analyst_t1 (ws01)
$ErrorActionPreference = 'Continue'
$mp = 'mbr02.range.local'
Write-Output '=== curl --negotiate: Device read with cached Administrator ST ==='
curl.exe -k --negotiate -u : -s -o - -w "`nHTTP_CODE=%{http_code}`n" "https://$mp/AdminService/v1.0/Device(16777219)" 2>&1 | Select-Object -Last 20

Write-Output ''
Write-Output '=== curl --negotiate: root /AdminService/v1.0/ ==='
curl.exe -k --negotiate -u : -s -o - -w "`nHTTP_CODE=%{http_code}`n" "https://$mp/AdminService/v1.0/" 2>&1 | Select-Object -Last 10
Write-Output 'CURL_DONE'
