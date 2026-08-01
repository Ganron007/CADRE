$ErrorActionPreference = "Stop"
Write-Output "=== curl AdminService debug ==="
$out = & curl.exe -k -sS --ntlm -u "range\svc_sccm:s3rv1c3_SCCM!" --max-time 20 "https://mbr02.range.local/AdminService/wmi/" 2>&1
Write-Output "CURL_EXIT=$LASTEXITCODE"
$outStr = [string]$out
Write-Output "CURL_OUTLEN=$($outStr.Length)"
if ($outStr.Length -gt 0) { Write-Output ("CURL_OUT_FIRST400=" + $outStr.Substring(0, [Math]::Min(400, $outStr.Length))) }
$null = & curl.exe -k -s -o NUL -w "CURL_HTTP=%{http_code}`n" --ntlm -u "range\svc_sccm:s3rv1c3_SCCM!" --max-time 20 "https://mbr02.range.local/AdminService/wmi/" 2>&1
Write-Output "DONE"
