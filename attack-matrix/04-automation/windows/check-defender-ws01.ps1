$ErrorActionPreference = 'SilentlyContinue'
$st = Get-Service WinDefend
$pol = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name DisableAntiSpyware).DisableAntiSpyware
$sm = (Get-CimInstance Win32_Service -Filter "Name='WinDefend'").StartMode
$mps = Get-MpComputerStatus
Write-Output ("WINDEFEND=" + $st.Status + "|startmode=" + $sm + "|DisableAntiSpyware=" + $pol)
if ($mps) {
  Write-Output ("MPSTAT|RTP=" + $mps.RealTimeProtectionEnabled + "|TP=" + $mps.IsTamperProtected + "|AV=" + $mps.AntivirusEnabled + "|AMService=" + $mps.AMServiceEnabled)
} else {
  Write-Output "MPSTAT|(Get-MpComputerStatus unavailable)"
}
# Check the feature keys that full-kill was supposed to set
$feat = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Features' -ErrorAction SilentlyContinue
if ($feat) {
  Write-Output ("FEATURES|TamperProtection=" + $feat.TamperProtection + "|MaxProtection=" + $feat.MaxProtection)
}
$policies = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection' -ErrorAction SilentlyContinue
if ($policies) {
  Write-Output ("RTP_POLICY|DisableRealtime=" + $policies.DisableRealtimeMonitoring + "|DisableBehavior=" + $policies.DisableBehaviorMonitoring + "|DisableOnAccess=" + $policies.DisableOnAccessProtection + "|DisableIOAV=" + $policies.DisableIOAVProtection)
}
