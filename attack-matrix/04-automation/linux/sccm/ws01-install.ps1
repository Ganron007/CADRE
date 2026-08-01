# Install SCCM client on ws01 — analyst_t1 (CONFIG channel, clean single-role client)
$ErrorActionPreference = 'Continue'
$src = 'C:\Users\analyst_t1\ccm_client'

Write-Output '=== 1. Create source dir + download from MP ==='
New-Item -ItemType Directory -Path $src -Force | Out-Null
foreach ($f in @('ccmsetup.exe','ccmsetup.cab','client.msi')) {
  try {
    Invoke-WebRequest -Uri "http://mbr02.range.local/CCM_Client/$f" -OutFile "$src\$f" -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
    Write-Output ("  downloaded " + $f + " (" + (Get-Item "$src\$f").Length + " bytes)")
  } catch { Write-Output ("  download " + $f + " ERROR: " + $_.Exception.Message) }
}

Write-Output '=== 2. Launch ccmsetup (correct property syntax) ==='
$cmd = "`"$src\ccmsetup.exe`" /mp:mbr02.range.local SMSSITECODE=CAD SMSMP=mbr02.range.local /NoCRLCheck"
Write-Output ("  CMDLINE: " + $cmd)
Set-Content -Path 'C:\Users\analyst_t1\ccm-install.cmd' -Value $cmd -Encoding ASCII
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','C:\Users\analyst_t1\ccm-install.cmd' -WindowStyle Hidden -PassThru
Write-Output ("  LAUNCH_PID=" + $p.Id)
Start-Sleep -Seconds 20

Write-Output '=== 3. State 20s after launch ==='
$c = 'HKLM:\SOFTWARE\Microsoft\CCM'
if (Test-Path $c) { $cp = Get-ItemProperty $c -ErrorAction SilentlyContinue; Write-Output ("  CCM\AssignedSiteCode=" + $cp.AssignedSiteCode) } else { Write-Output '  CCM reg absent yet' }
$mc = 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client'
if (Test-Path $mc) { $m = Get-ItemProperty $mc -ErrorAction SilentlyContinue; Write-Output ("  SMS\Mobile Client\AssignedSiteCode=" + $m.AssignedSiteCode) } else { Write-Output '  SMS\Mobile Client absent yet' }
Get-Service CcmExec -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("  CcmExec=" + $_.Status) }
Write-Output '=== 4. ccmsetup.log tail ==='
$log = 'C:\Windows\ccmsetup\Logs\ccmsetup.log'
if (Test-Path $log) { Get-Content $log -Tail 12 | ForEach-Object { if ($_ -match '<LOG\[(.*?)\]LOG\]!>') { Write-Output ("  " + $matches[1]) } else { Write-Output ("  " + $_) } } } else { Write-Output '  (no ccmsetup.log yet)' }
Write-Output 'WS01_INSTALL_DONE'
