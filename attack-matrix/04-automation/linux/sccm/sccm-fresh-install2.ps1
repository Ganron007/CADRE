# FRESH install v2 — NO /mp (documented fix for 0x87d0027e), pure local source — CONFIG, vagrant
#   ccmsetup params:  /source (local), /NoCRLCheck
#   client.msi props (NO slash): SMSSITECODE=CAD, SMSMP=mbr02.range.local
$ErrorActionPreference = 'Continue'

Write-Output '=== Stop any lingering ccmsetup retry loop ==='
Get-Service ccmsetup -ErrorAction SilentlyContinue | Stop-Service -Force -ErrorAction SilentlyContinue
Get-Process ccmsetup -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Write-Output '  cleaned'

Write-Output '=== Launch install from LOCAL source (no /mp) ==='
$src = 'C:\Windows\Temp\SMSSETUP\CLIENT'
$cmd = "`"$src\ccmsetup.exe`" /source:$src SMSSITECODE=CAD SMSMP=mbr02.range.local /NoCRLCheck"
Write-Output ("  CMDLINE: " + $cmd)
Set-Content -Path 'C:\Windows\Temp\cadre-client-install2.cmd' -Value $cmd -Encoding ASCII
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','C:\Windows\Temp\cadre-client-install2.cmd' -WindowStyle Hidden -PassThru
Write-Output ("  LAUNCH_PID=" + $p.Id)
Start-Sleep -Seconds 20

Write-Output '=== State 20s after launch ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
if (Test-Path $c) { $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue; Write-Output ("  AssignedSiteCode=" + $cp.AssignedSiteCode) } else { Write-Output '  CCM reg GONE' }
Write-Output ("  CCM_DIR=" + (Test-Path 'C:\Windows\CCM'))
Write-Output '=== ccmsetup.log tail ==='
Get-Content 'C:\Windows\ccmsetup\Logs\ccmsetup.log' -Tail 20 -ErrorAction SilentlyContinue | ForEach-Object { Write-Output $_ }
Write-Output 'INSTALL2_DONE'
