# Repair MP web handlers via mp.msi - cmd /c approach (matches rolesetup.exe invocation)
$ErrorActionPreference = 'Continue'
Write-Output '=== WT038 MP repair attempt ==='
$msi = 'C:\Program Files\Microsoft Configuration Manager\bin\x64\mp.msi'
$log = 'C:\Program Files\Microsoft Configuration Manager\logs\mpRepair.log'
Write-Output ('  msi exists: ' + (Test-Path $msi))
if (-not (Test-Path $msi)) { Write-Output '  ABORT: mp.msi not found'; exit 1 }

# Delete stale log if present
Remove-Item $log -ErrorAction SilentlyContinue

$cmdLine = 'C:\Windows\System32\msiexec.exe /i "' + $msi + '" REINSTALL=ALL REINSTALLMODE=vmaus CCMINSTALLDIR="C:\Program Files\SMS_CCM" CCMSERVERDATAROOT="C:\Program Files\Microsoft Configuration Manager" USESMSPORTS=TRUE SMSPORTS=80 USESMSSSLPORTS=TRUE SMSSSLPORTS=443 USESMSSSL=TRUE SMSSSLSTATE=1024 CCMENABLELOGGING=TRUE CCMLOGLEVEL=1 CCMLOGMAXSIZE=1000000 CCMLOGMAXHISTORY=1 /qn /norestart /l*v "' + $log + '"'
Write-Output ('  cmdline: ' + $cmdLine)
Write-Output '  launching msiexec (this takes ~5-6 min)...'
cmd /c $cmdLine
Write-Output ('  exit code: ' + $LASTEXITCODE)
Write-Output ('  log created: ' + (Test-Path $log))
if (Test-Path $log) { Write-Output '  log head:'; Get-Content $log -TotalCount 5 }
Write-Output '=== post check ==='
Write-Output ('  SMS_MP files=' + (Get-ChildItem 'C:\Program Files\SMS_CCM\SMS_MP' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count)
Write-Output ('  ServiceData\System files=' + (Get-ChildItem 'C:\Program Files\SMS_CCM\ServiceData\System' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count)
