# Verify HHW install + list hhc.exe locations
$ErrorActionPreference = 'Continue'
Write-Output '=== hhc.exe search ==='
Get-ChildItem 'C:\Program Files (x86)\HTML Help Workshop\hhc.exe' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "HHC|$($_.FullName)" }
Get-ChildItem 'C:\Program Files\HTML Help Workshop\hhc.exe' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "HHC|$($_.FullName)" }
# hh.exe viewer
Test-Path 'C:\Windows\hh.exe'
# any hhc on disk
Get-ChildItem C:\Tools -Recurse -Filter 'hhc.exe' -ErrorAction SilentlyContinue | Select-Object -First 3 | ForEach-Object { Write-Output "HHC_TOOLS|$($_.FullName)" }
Write-Output 'HHW_CHECK_DONE'
