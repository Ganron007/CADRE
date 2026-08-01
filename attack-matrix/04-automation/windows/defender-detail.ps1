$ErrorActionPreference = 'Continue'
$svc = Get-Service WinDefend -ErrorAction SilentlyContinue
$sm = ''
if ($svc) { $sm = (Get-CimInstance Win32_Service -Filter "Name='WinDefend'" -ErrorAction SilentlyContinue).StartMode }
$os = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber
$pol = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' -Name DisableAntiSpyware -ErrorAction SilentlyContinue
Write-Output "OS=$($os.Caption) VER=$($os.Version) BUILD=$($os.BuildNumber)"
Write-Output "WINDEFEND=$($svc.Status)|startmode=$sm|DisableAntiSpyware=$($pol.DisableAntiSpyware)"
try {
  $mps = Get-MpComputerStatus
  Write-Output "MPSTAT RTP=$($mps.RealTimeProtectionEnabled) TP=$($mps.IsTamperProtected) AV=$($mps.AntivirusEnabled) AMSvc=$($mps.AMServiceEnabled)"
} catch { Write-Output "MPSTAT_ERR $($_.Exception.Message)" }
# Exclusion paths for tooling
$excl = Get-MpPreference -ErrorAction SilentlyContinue
Write-Output "EXCL_PATHS=$($excl.ExclusionPath -join ';')"
Write-Output "EXCL_PROCS=$($excl.ExclusionProcess -join ';')"
Write-Output "DONE"
