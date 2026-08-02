# H setup finish: copy AutoIt3 + download WiX + HHW (robust, per-step)
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'

# 1. Copy AutoIt3.exe from extracted dir
$ai = Get-ChildItem "$www\autoit" -Recurse -Filter 'AutoIt3.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($ai) {
    Copy-Item $ai.FullName "$www\AutoIt3.exe" -Force
    Write-Output "AUTOIT_EXE $($ai.FullName) -> $((Get-Item "$www\AutoIt3.exe").Length) bytes"
} else { Write-Output 'AUTOIT_EXE_MISSING' }

# 2. WiX download (retry, longer timeout)
Write-Output '=== WIX ==='
if (-not (Test-Path "$www\wix314.zip")) {
    & curl.exe -L -sS --retry 3 --max-time 300 -o "$www\wix314.zip" 'https://github.com/wixtoolset/wix3/releases/download/wix3141rtm/wix314-binaries.zip' 2>&1 | Out-Null
}
if (Test-Path "$www\wix314.zip") {
    Write-Output "WIX_ZIP $((Get-Item "$www\wix314.zip").Length)"
    Expand-Archive "$www\wix314.zip" "$www\wix" -Force
    Write-Output "WIX_CANDLE $(Test-Path "$www\wix\candle.exe") WIX_LIGHT $(Test-Path "$www\wix\light.exe")"
} else { Write-Output 'WIX_FAILED' }

# 3. HHW download
Write-Output '=== HHW ==='
if (-not (Test-Path "$www\htmlhelp.exe")) {
    & curl.exe -L -sS --retry 3 --max-time 180 -o "$www\htmlhelp.exe" 'https://download.microsoft.com/download/0/A/9/0A939EF6-E31C-430F-A3DF-DFAE7960D564/htmlhelp.exe' 2>&1 | Out-Null
}
Write-Output "HHW_SETUP_EXISTS $(Test-Path "$www\htmlhelp.exe")"
if (Test-Path "$www\htmlhelp.exe") { Write-Output "HHW_SIZE $((Get-Item "$www\htmlhelp.exe").Length)" }

Write-Output '=== FINAL WWW ==='
Get-ChildItem $www | Select-Object Name, Length | Format-Table -AutoSize | Out-String
Write-Output 'H_SETUP_FINISH_DONE'
