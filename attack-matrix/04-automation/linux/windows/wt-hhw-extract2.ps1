# Get portable 7-Zip on ws01 + extract hhc.exe from HHW installer
$ErrorActionPreference = 'Continue'
$www = 'C:\Tools\campaign-h\www'

# 1. Download 7zr.exe + 7-Zip extra package
& curl.exe -L -sS --max-time 120 -o "$www\7zr.exe" 'https://www.7-zip.org/a/7zr.exe' 2>&1 | Out-Null
Write-Output "7ZR_EXISTS $(Test-Path "$www\7zr.exe")"
if (Test-Path "$www\7zr.exe") { Write-Output "7ZR_SIZE $((Get-Item "$www\7zr.exe").Length)" }

& curl.exe -L -sS --max-time 180 -o "$www\7z-extra.7z" 'https://www.7-zip.org/a/7z2409-extra.7z' 2>&1 | Out-Null
Write-Output "EXTRA_EXISTS $(Test-Path "$www\7z-extra.7z")"

# 2. Extract extra package (7za.exe)
if (Test-Path "$www\7zr.exe") {
    New-Item -ItemType Directory -Path "$www\7z" -Force | Out-Null
    & "$www\7zr.exe" x "$www\7z-extra.7z" "-o$www\7z" -y 2>&1 | Select-Object -Last 3 | ForEach-Object { Write-Output "7ZR|$_" }
    Get-ChildItem "$www\7z" -Filter '7za.exe' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "7ZA|$($_.FullName)" }
}

# 3. Extract hhc.exe from htmlhelp.exe
$za = Get-ChildItem "$www\7z" -Filter '7za.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($za) {
    New-Item -ItemType Directory -Path "$www\hhw" -Force | Out-Null
    & $za.FullName x "$www\htmlhelp.exe" "-o$www\hhw" -y 2>&1 | Select-Object -Last 4 | ForEach-Object { Write-Output "7ZA_X|$_" }
    Get-ChildItem "$www\hhw" -Recurse -Filter 'hhc.exe' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "HHC_EXTRACTED|$($_.FullName)|$($_.Length)" }
    Get-ChildItem "$www\hhw" -ErrorAction SilentlyContinue | Select-Object -First 10 | ForEach-Object { Write-Output "EXTRACT|$($_.Name)" }
} else { Write-Output 'NO_7ZA' }
Write-Output 'HHW_EXTRACT_DONE'
