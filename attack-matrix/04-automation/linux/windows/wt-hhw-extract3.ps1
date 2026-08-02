# Retry: 7z2602-extra.7z + extract hhc.exe
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'

& curl.exe -L -sS --max-time 180 -o "$www\7z-extra.7z" 'https://www.7-zip.org/a/7z2602-extra.7z' 2>&1 | Out-Null
Write-Output "EXTRA_SIZE $((Get-Item "$www\7z-extra.7z" -ErrorAction SilentlyContinue).Length)"

if ((Get-Item "$www\7z-extra.7z" -ErrorAction SilentlyContinue).Length -gt 10000) {
    New-Item -ItemType Directory -Path "$www\7z" -Force | Out-Null
    & "$www\7zr.exe" x "$www\7z-extra.7z" "-o$www\7z" -y 2>&1 | Select-Object -Last 2 | ForEach-Object { Write-Output "7ZR|$_" }
    $za = Get-ChildItem "$www\7z" -Filter '7za.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($za) {
        Write-Output "7ZA_FOUND $($za.FullName)"
        New-Item -ItemType Directory -Path "$www\hhw" -Force | Out-Null
        & $za.FullName x "$www\htmlhelp.exe" "-o$www\hhw" -y 2>&1 | Select-Object -Last 4 | ForEach-Object { Write-Output "7ZA_X|$_" }
        Get-ChildItem "$www\hhw" -Recurse -Filter 'hhc.exe' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "HHC_EXTRACTED|$($_.FullName)|$($_.Length)" }
        Get-ChildItem "$www\hhw" -ErrorAction SilentlyContinue | Select-Object -First 12 | ForEach-Object { Write-Output "EXTRACT|$($_.Name)" }
    } else { Write-Output 'NO_7ZA_IN_EXTRA' }
} else { Write-Output 'EXTRA_DOWNLOAD_BAD' }
Write-Output 'HHW_EXTRACT2_DONE'
