# Mini: cat mimikatz raw output file
$ErrorActionPreference = 'Continue'
$p = 'C:\Windows\Temp\cadre-mimikatz-live.txt'
if (Test-Path $p) { Get-Content $p -Raw } else { Write-Output 'FILE_MISSING' }
Write-Output '---CAT_END---'
