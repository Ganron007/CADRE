# Verify mimikatz-latest version + retry Rubeus via curl
$ErrorActionPreference = 'Continue'
$out = 'C:\Tools\ADTools'

Write-Output '=== MIMIKATZ-LATEST VERSION ==='
cmd.exe /c "`"$out\mimikatz-latest\x64\mimikatz.exe`" version exit > `"$out\mik-latest-ver.out`" 2>&1"
Get-Content "$out\mik-latest-ver.out" | Select-Object -First 5 | ForEach-Object { Write-Output "MIKVER|$_" }

Write-Output '=== RUBEUS VIA CURL ==='
$curl = Get-Command curl.exe -ErrorAction SilentlyContinue
if ($curl) {
    & curl.exe -L -sS -o "$out\Rubeus-official.exe" 'https://github.com/GhostPack/Rubeus/releases/latest/download/Rubeus.exe' 2>&1 | Select-Object -First 5 | ForEach-Object { Write-Output "CURL|$_" }
    if (Test-Path "$out\Rubeus-official.exe") { Write-Output "RUBEUS_SIZE $((Get-Item "$out\Rubeus-official.exe").Length)" }
} else { Write-Output 'NO_CURL' }

Write-Output 'VERIFY_DONE'
