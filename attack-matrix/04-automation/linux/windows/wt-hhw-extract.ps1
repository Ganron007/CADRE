# Extract hhc.exe from the HHW installer via 7-Zip (no admin needed)
$ErrorActionPreference = 'Continue'

$seven = @('C:\Program Files\7-Zip\7z.exe','C:\Program Files (x86)\7-Zip\7z.exe','C:\Tools\ADTools\7z\7z.exe') | Where-Object { Test-Path $_ } | Select-Object -First 1
Write-Output "SEVENZIP $seven"

if ($seven) {
    $src = 'C:\Tools\campaign-h\www\htmlhelp.exe'
    $dst = 'C:\Tools\campaign-h\www\hhw-extract'
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
    & $seven x $src "-o$dst" -y 2>&1 | Select-Object -Last 5 | ForEach-Object { Write-Output "7Z|$_" }
    Get-ChildItem $dst -Recurse -Filter 'hhc.exe' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "HHC_EXTRACTED|$($_.FullName)|$($_.Length)" }
    Get-ChildItem $dst -ErrorAction SilentlyContinue | Select-Object -First 15 | ForEach-Object { Write-Output "EXTRACT|$($_.Name)" }
} else { Write-Output 'NO_7ZIP' }
Write-Output 'EXTRACT_DONE'
