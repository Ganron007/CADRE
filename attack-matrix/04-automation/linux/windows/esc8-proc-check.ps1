# Check running python procs + listener ports during ESC8
$ErrorActionPreference = "Continue"
Write-Output "=== python processes ==="
Get-Process python -ErrorAction SilentlyContinue | Format-Table Id,CPU,StartTime,Path -AutoSize
Write-Output "=== listeners 445/80/443 ==="
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
  Where-Object { $_.LocalPort -in 445,80,443 } |
  Format-Table LocalAddress,LocalPort,OwningProcess -AutoSize
