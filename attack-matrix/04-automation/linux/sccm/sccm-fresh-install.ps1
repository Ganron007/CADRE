# FRESH client install with CORRECT syntax — CONFIG, vagrant
# Root cause fixed: SMSSITECODE/SMSMP are client.msi PROPERTIES (NO slash).
#   ccmsetup params (slash):  /MP, /NoCRLCheck, /source
#   client.msi props (no slash): SMSSITECODE=CAD, SMSMP=mbr02.range.local
$ErrorActionPreference = 'Continue'

Write-Output '=== PRE-INSTALL STATE ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
if (Test-Path $c) { $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue; Write-Output ("  AssignedSiteCode=" + $cp.AssignedSiteCode) } else { Write-Output '  CCM reg GONE' }
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec=" + $_.Status) }
Write-Output ("  SMS_CCM_DIR=" + (Test-Path 'C:\Program Files\SMS_CCM'))
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))

Write-Output '=== C:\tmp (user-specified package location) ==='
if (Test-Path 'C:\tmp') { Get-ChildItem 'C:\tmp' -ErrorAction SilentlyContinue | Select-Object -First 15 | ForEach-Object { Write-Output ('  ' + $_.Name + ' | ' + $_.Length) } } else { Write-Output '  NO C:\tmp' }

Write-Output '=== Source check ==='
$src = 'C:\Windows\Temp\SMSSETUP\CLIENT'
Write-Output ("  SOURCE_EXISTS=" + (Test-Path "$src\ccmsetup.exe"))
if (Test-Path "$src\ccmsetup.exe") { Get-Item "$src\ccmsetup.exe" | ForEach-Object { Write-Output ("  ccmsetup ver=" + $_.VersionInfo.FileVersion) } }

Write-Output '=== Launch CORRECT install from local source ==='
$cmd = "`"$src\ccmsetup.exe`" /MP:mbr02.range.local SMSSITECODE=CAD SMSMP=mbr02.range.local /NoCRLCheck"
Write-Output ("  CMDLINE: " + $cmd)
Set-Content -Path 'C:\Windows\Temp\cadre-client-install.cmd' -Value $cmd -Encoding ASCII
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','C:\Windows\Temp\cadre-client-install.cmd' -WindowStyle Hidden -PassThru
Write-Output ("  LAUNCH_PID=" + $p.Id)
Start-Sleep -Seconds 15
Write-Output 'INSTALL_LAUNCHED'
