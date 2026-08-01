# Re-run ccmsetup WITHOUT RESETKEYINFORMATION — test the hypothesis — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$src = 'C:\Windows\Temp\SMSSETUP\CLIENT'

Write-Output '=== Before ==='
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
if (Test-Path $mc) { $m = Get-ItemProperty $mc -ErrorAction SilentlyContinue; Write-Output ("  SMS\Mobile Client\AssignedSiteCode=" + $m.AssignedSiteCode) } else { Write-Output '  SMS\Mobile Client absent' }
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
if (Test-Path $c) { $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue; Write-Output ("  CCM\AssignedSiteCode=" + $cp.AssignedSiteCode) } else { Write-Output '  CCM absent' }

Write-Output '=== Launch ccmsetup (no RESETKEYINFORMATION) ==='
$cmd = "`"$src\ccmsetup.exe`" /source:$src SMSSITECODE=CAD SMSMP=mbr02.range.local /NoCRLCheck"
Write-Output ("  CMDLINE: " + $cmd)
Set-Content -Path 'C:\Windows\Temp\cadre-client-nork.cmd' -Value $cmd -Encoding ASCII
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','C:\Windows\Temp\cadre-client-nork.cmd' -WindowStyle Hidden -PassThru
Write-Output ("  LAUNCH_PID=" + $p.Id)
Start-Sleep -Seconds 25

Write-Output '=== After 25s ==='
if (Test-Path $mc) { $m = Get-ItemProperty $mc -ErrorAction SilentlyContinue; Write-Output ("  SMS\Mobile Client\AssignedSiteCode=" + $m.AssignedSiteCode) } else { Write-Output '  SMS\Mobile Client absent' }
if (Test-Path $c) { $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue; Write-Output ("  CCM\AssignedSiteCode=" + $cp.AssignedSiteCode + " SMS_MP=" + $cp.SMS_MP) } else { Write-Output '  CCM absent' }
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec=" + $_.Status) }
Write-Output '=== ccmsetup.log tail 12 ==='
Get-Content 'C:\Windows\ccmsetup\Logs\ccmsetup.log' -Tail 12 -ErrorAction SilentlyContinue | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } }
Write-Output 'NORK_DONE'
