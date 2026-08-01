# Read ccmsetup log tail on mbr02 — run from ws01 as svc_naa
$ErrorActionPreference = 'Continue'
net use \\mbr02.range.local\C$ /user:RANGE\svc_naa 'N@A_s3rv1c3!' 2>&1 | Out-Null
Write-Output '=== CCMSetup folder logs ==='
Get-ChildItem '\\mbr02.range.local\C$\Windows\CCMSetup\Logs\*.log' -ErrorAction SilentlyContinue | Select-Object Name, LastWriteTime, Length | Format-Table -AutoSize | Out-String -Width 120 | Write-Output
Write-Output '=== ccmsetup.log tail (last 40) ==='
$log = '\\mbr02.range.local\C$\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) { Get-Content $log -Tail 40 } else { Write-Output 'NO LOG' }
Write-Output '=== ccmsetup*.log in CCMSetup root ==='
Get-ChildItem '\\mbr02.range.local\C$\Windows\CCMSetup\*.log' -ErrorAction SilentlyContinue | Select-Object Name, LastWriteTime | Format-Table -AutoSize | Out-String -Width 120 | Write-Output
net use \\mbr02.range.local\C$ /delete 2>&1 | Out-Null
Write-Output 'LOG_DONE'
