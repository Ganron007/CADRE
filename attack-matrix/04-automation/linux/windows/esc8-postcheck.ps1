# ESC8 v5 post-check: relay process, coercer log, certs, listener state
$ErrorActionPreference = "Continue"
$work = "C:\Tools\cadre-attack"

Write-Output "=== python processes ==="
Get-Process python -ErrorAction SilentlyContinue | Format-Table Id,CPU,StartTime,Path -AutoSize

Write-Output "=== 8445/445 listeners ==="
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
  Where-Object { $_.LocalPort -in 8445,445,80 } |
  Format-Table LocalAddress,LocalPort,OwningProcess -AutoSize

Write-Output "=== coercer log (tail) ==="
Get-Content (Join-Path $work "esc8-coercer.log") -Tail 40 -ErrorAction SilentlyContinue

Write-Output "=== relay stderr (tail) ==="
Get-Content (Join-Path $work "esc8-relay.err") -Tail 10 -ErrorAction SilentlyContinue

Write-Output "=== certs in workdir (newest first) ==="
Get-ChildItem $work -Filter "*.pfx" | Sort-Object LastWriteTime -Descending | Format-Table Name,Length,LastWriteTime -AutoSize

Write-Output "=== SMB services state ==="
Get-Service LanmanServer -ErrorAction SilentlyContinue | Format-Table Status,Name -AutoSize
sc.exe query srv2 | Select-String STATE
sc.exe query srvnet | Select-String STATE
