# Recon: hashes, tools, ctfmon state for validation batch 2 (2026-08-03)
$ErrorActionPreference = 'Continue'

Write-Output '=== DC-SYNC FILES ==='
Get-ChildItem C:\Tools -Recurse -Filter '*dcsync*' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
Get-ChildItem C:\Tools -Recurse -Filter '*krbtgt*' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

Write-Output '=== MACHINE HASHES (mbr01-dcsync.txt) ==='
$f = Get-ChildItem C:\Tools -Recurse -Filter 'mbr01-dcsync.txt' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($f) {
    Get-Content $f.FullName | Select-String -Pattern 'mbr01|dc01\$|dc02\$|dc03\$|krbtgt' | Select-Object -First 12 | ForEach-Object { $_.Line }
} else { Write-Output 'mbr01-dcsync.txt NOT FOUND' }

Write-Output '=== ROOT DCSYNC-OUT ==='
$f2 = Get-ChildItem C:\Tools -Recurse -Filter 'dcsync-out.txt' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($f2) {
    Write-Output "PATH=$($f2.FullName)"
    Get-Content $f2.FullName | Select-String -Pattern 'krbtgt|Administrator' | Select-Object -First 6 | ForEach-Object { $_.Line }
} else { Write-Output 'dcsync-out.txt NOT FOUND' }

Write-Output '=== PROCDUMP ==='
$pd = Get-ChildItem C:\Tools -Recurse -Filter 'procdump*.exe' -ErrorAction SilentlyContinue
if ($pd) { $pd | Select-Object -ExpandProperty FullName } else { Write-Output 'PROCDUMP NOT FOUND' }
Get-Command procdump* -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

Write-Output '=== CTFMON (ws01) ==='
Get-Process -Name ctfmon -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, SessionId | Format-Table -AutoSize | Out-String

Write-Output '=== Rubeus/mimikatz present ==='
Test-Path C:\Tools\ADTools\Rubeus.exe
Test-Path C:\Tools\ADTools\mimikatz.exe
Test-Path C:\Tools\ADTools\SharpDPAPI.exe
Test-Path C:\Tools\ADTools\procdump.exe

Write-Output '=== RECON_DONE ==='
