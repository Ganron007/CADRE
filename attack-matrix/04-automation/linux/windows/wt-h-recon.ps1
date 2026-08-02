# Recon: H-campaign build tooling on ws01
$ErrorActionPreference = 'Continue'

Write-Output '=== TOOLS ON ws01 ==='
foreach ($t in @('AutoIt3.exe','candle.exe','light.exe','hhc.exe','hh.exe','csc.exe','python.exe','choco.exe')) {
    $found = Get-Command $t -ErrorAction SilentlyContinue
    if ($found) { Write-Output "CMD|$t -> $($found.Source)" } else { Write-Output "CMD|$t -> NOT FOUND" }
}
Write-Output '--- csc in .NET ---'
Test-Path 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
Write-Output '--- choco packages (installed) ---'
choco list --limit-output 2>$null | Select-String -Pattern 'wixtoolset|autohotkey|autoit' | Select-Object -First 10 | ForEach-Object { Write-Output "CHOCO|$_" }
Write-Output '--- hh.exe (HTML Help viewer) ---'
Test-Path 'C:\Windows\System32\hh.exe'
Write-Output '--- msiexec ---'
(Get-Command msiexec -ErrorAction SilentlyContinue).Source

Write-Output '=== EXISTING H payloads / hosters on ws01 ==='
Get-ChildItem C:\Tools -Recurse -Filter 'payload.exe' -ErrorAction SilentlyContinue | Select-Object -First 5 | ForEach-Object { Write-Output "PAYLOAD|$($_.FullName)|$($_.Length)" }
Get-ChildItem C:\Tools -Recurse -Filter 'AutoIt3.exe' -ErrorAction SilentlyContinue | Select-Object -First 3 | ForEach-Object { Write-Output "AUTOIT|$($_.FullName)" }
Get-ChildItem C:\Tools -Recurse -Filter '*.wxs' -ErrorAction SilentlyContinue | Select-Object -First 3 | ForEach-Object { Write-Output "WXS|$($_.FullName)" }

Write-Output '=== HTTP server running? (provisioning :8081 from ws01) ==='
$c = Test-NetConnection 192.168.77.60 -Port 8081 -WarningAction SilentlyContinue
Write-Output "PROVISIONING_8081 $($c.TcpTestSucceeded)"

Write-Output '=== whoami context ==='
whoami

Write-Output 'H_RECON_DONE'
