# Recon: newer mimikatz / rubeus-src / dotnet / internet on ws01
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'

Write-Output '=== MIMIKATZ_TRUNK ==='
$mt = Get-ChildItem "$out\mimikatz_trunk" -Recurse -Filter 'mimikatz.exe' -ErrorAction SilentlyContinue
if ($mt) { $mt | ForEach-Object { Write-Output "MIK_TRUNK_EXE|$($_.FullName)|$($_.Length)" } } else { Write-Output 'NO_TRUNK_EXE (zip-only?)' }
Get-ChildItem "$out\mimikatz_trunk" -ErrorAction SilentlyContinue | Select-Object -First 15 | ForEach-Object { Write-Output "TRUNK_TOP|$($_.Name)" }
Get-ChildItem "$out\mimikatz_trunk.zip" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "TRUNK_ZIP|$($_.Length)" }

Write-Output '=== RUBEUS-SRC ==='
$rs = Get-ChildItem "$out\rubeus-src" -ErrorAction SilentlyContinue | Select-Object -First 20
if ($rs) { $rs | ForEach-Object { Write-Output "RSRC|$($_.Name)" } } else { Write-Output 'NO_RUBEUS_SRC' }
Get-ChildItem "$out\Rubeus-master.zip" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "RUBEUS_ZIP|$($_.Length)" }

Write-Output '=== DOTNET ==='
$dn = Get-Command dotnet -ErrorAction SilentlyContinue
if ($dn) { Write-Output "DOTNET $($dn.Source)" } else { Write-Output 'NO_DOTNET' }
Get-ChildItem 'C:\Program Files\dotnet\dotnet.exe' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "DOTNET_EXE $($_.FullName)" }

Write-Output '=== INTERNET CHECK ==='
$conn = Test-NetConnection github.com -Port 443 -WarningAction SilentlyContinue
Write-Output "GH443 $($conn.TcpTestSucceeded)"

Write-Output '=== RUBEUS VERSION (bare) ==='
cmd.exe /c "`"$out\Rubeus.exe`" > `"$out\rubeus-bare2.out`" 2>&1"
Get-Content "$out\rubeus-bare2.out" -ErrorAction SilentlyContinue | Select-Object -First 15 | ForEach-Object { Write-Output "RUBEUS_BARE|$_" }

Write-Output 'RECON3_DONE'
