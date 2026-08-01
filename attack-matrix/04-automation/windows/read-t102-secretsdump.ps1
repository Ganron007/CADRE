$ErrorActionPreference = 'Continue'
$dir = 'C:\Tools\cadre-attack\T102-capture'
Write-Output "DIR=$dir exists=$(Test-Path $dir)"
if (Test-Path $dir) {
    Get-ChildItem $dir | ForEach-Object { Write-Output "FILE|$($_.Name)|$($_.Length)" }
}
$out = Join-Path $dir 'secretsdump-out.txt'
if (Test-Path $out) {
    Write-Output "--- secretsdump-out.txt ---"
    Get-Content $out | ForEach-Object { Write-Output "SD|$_" }
} else {
    Write-Output 'NO_SECRETSDUMP_OUT'
}
