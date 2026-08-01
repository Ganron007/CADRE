# Locate ccmclean on mbr02 + official client uninstall — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Write-Output '=== 1. Search mbr02 for ccmclean.exe ==='
$found = Get-ChildItem 'C:\' -Recurse -Filter 'ccmclean.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
Write-Output ('  CCMCLEAN=' + $found)
if (-not $found) {
  Write-Output '=== 2. Not found -> use official built-in: ccmsetup /uninstall ==='
  $ccm = 'C:\Windows\CCMSetup\ccmsetup.exe'
  if (-not (Test-Path $ccm)) { Copy-Item 'C:\Program Files\Microsoft Configuration Manager\Client\ccmsetup.exe' $ccm -Force -ErrorAction SilentlyContinue }
  if (Test-Path $ccm) {
    Set-Content -Path 'C:\Windows\Temp\ccm_uninstall.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /uninstall' -Encoding ascii
    $p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_uninstall.cmd' -PassThru -WindowStyle Hidden
    Write-Output ('  UNINSTALL_PID=' + $p.Id)
    Start-Sleep -Seconds 90
    Write-Output '=== 3. Verify uninstall ==='
    Write-Output ('  CCMEXEC_SVC=' + (Get-Service CcmExec -ErrorAction SilentlyContinue).Status)
    Write-Output ('  CCM_DIR=' + (Test-Path 'C:\Windows\CCM'))
    Write-Output ('  SMS_CCM_DIR=' + (Test-Path 'C:\Program Files\SMS_CCM'))
    Write-Output ('  CCM_REG=' + (Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM'))
    try { $null = Get-CimInstance -Namespace root\CCM -ClassName SMS_Client -ErrorAction Stop; Write-Output '  ROOTCCM=STILL_EXISTS' } catch { Write-Output '  ROOTCCM=GONE' }
  } else { Write-Output '  NO_CCMSETUP_TOOL' }
}
Write-Output 'UNINSTALL_DONE'
