# Assign installed-but-unassigned client via the applet-equivalent registry values — CONFIG, vagrant
# Client MSI already installed (confirmed); site published in AD (confirmed in log).
# Set AssignedSiteCode + SMS_MP exactly as the SCCM client Properties applet does, restart CcmExec.
$ErrorActionPreference = 'Continue'

Write-Output '=== Current state before ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
$cp = Get-ItemProperty $c -ErrorAction SilentlyContinue
Write-Output ("  CCM\AssignedSiteCode=" + $cp.AssignedSiteCode)
Write-Output ("  CCM\SMS_MP=" + $cp.SMS_MP)
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
$mp = Get-ItemProperty $mc -ErrorAction SilentlyContinue
Write-Output ("  SMS\Mobile Client\AssignedSiteCode=" + $mp.AssignedSiteCode)

Write-Output '=== Setting site assignment (applet-equivalent) ==='
New-Item -Path $c -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $mc -Force -ErrorAction SilentlyContinue | Out-Null
New-ItemProperty -Path $c -Name AssignedSiteCode -Value 'CAD' -PropertyType String -Force | Out-Null
New-ItemProperty -Path $c -Name SMS_MP -Value 'mbr02.range.local' -PropertyType String -Force | Out-Null
New-ItemProperty -Path $mc -Name AssignedSiteCode -Value 'CAD' -PropertyType String -Force | Out-Null
New-ItemProperty -Path $mc -Name 'AssignedSites' -Value 'CAD' -PropertyType String -Force | Out-Null
Write-Output '  values written'

Write-Output '=== Restart CcmExec ==='
Restart-Service CcmExec -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 10
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec=" + $_.Status) }

Write-Output '=== State 10s after restart ==='
$cp2 = Get-ItemProperty $c -ErrorAction SilentlyContinue
Write-Output ("  CCM\AssignedSiteCode=" + $cp2.AssignedSiteCode)
Write-Output ("  CCM\SMS_MP=" + $cp2.SMS_MP)
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))
Write-Output 'ASSIGN_DONE'
