$ErrorActionPreference = 'Continue'
$st = Get-MpComputerStatus -ErrorAction SilentlyContinue
if ($st) {
  Write-Output "RTP=$($st.RealTimeProtectionEnabled) TP=$($st.IsTamperProtected) AV=$($st.AntivirusEnabled) AMSvc=$($st.AMServiceEnabled)"
} else {
  Write-Output "NO_MP_STATUS (Defender removed or not present)"
}
$svc = Get-Service WinDefend -ErrorAction SilentlyContinue
if ($svc) {
  $sm = (Get-CimInstance Win32_Service -Filter "Name='WinDefend'").StartMode
  Write-Output "WINDEFEND=$($svc.Status)|startmode=$sm"
} else {
  Write-Output "WINDEFEND_SERVICE_MISSING"
}
$pol = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name 'DisableAntiSpyware' -ErrorAction SilentlyContinue
Write-Output "POLICY_DISABLE_ANTISPYWARE $($pol.DisableAntiSpyware)"
