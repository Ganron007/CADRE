$ErrorActionPreference = 'Continue'
Write-Output "--- Rubeus.exe exists? ---"
Get-Item 'C:\Tools\ADTools\Rubeus.exe' -ErrorAction SilentlyContinue | Select-Object Name, Length, LastWriteTime | ForEach-Object { Write-Output "RUBEUS|$($_.Name)|$($_.Length)|$($_.LastWriteTime)" }
if (-not (Test-Path 'C:\Tools\ADTools\Rubeus.exe')) {
    Write-Output 'RUBEUS_MISSING'
}
Write-Output "--- file scan basic ---"
Get-FileHash 'C:\Tools\ADTools\Rubeus.exe' -Algorithm SHA256 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Hash
Write-Output "--- Defender detection history (tail) ---"
Get-MpThreatDetection -ErrorAction SilentlyContinue | Select-Object -Last 10 | ForEach-Object { Write-Output "DETECT|$($_.ThreatID)|$($_.Resources)" }
Get-MpThreat -ErrorAction SilentlyContinue | Select-Object -Last 5 | ForEach-Object { Write-Output "THREAT|$($_.ThreatName)|$($_.SeverityID)" }
