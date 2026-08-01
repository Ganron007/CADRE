# Clean /source client install + boundary schema introspect — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
$ns = 'root\SMS\site_CAD'

Write-Output '=== A) Clean kill ccmsetup ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 3
$still = tasklist | findstr /i ccmsetup
if ($still) { Write-Output ('STILL_RUNNING: ' + $still) } else { Write-Output 'CCMSETUP_DEAD' }

Write-Output '=== B) Launch ccmsetup /source (local client source) ==='
$p = Start-Process -FilePath 'C:\Windows\CCMSetup\ccmsetup.exe' -ArgumentList '/source:"C:\Program Files\Microsoft Configuration Manager\Client" /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -PassThru -WindowStyle Hidden
Write-Output ('PID=' + $p.Id)
Start-Sleep -Seconds 25
$alive = Get-Process -Id $p.Id -ErrorAction SilentlyContinue
Write-Output ('ALIVE_25S=' + [bool]$alive)
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Write-Output '--- log tail (raw, last 6) ---'
  Get-Content $log -Tail 6
}
Write-Output '=== C) SMS_Boundary schema types ==='
try {
  $cc = Get-CimClass -ClassName SMS_Boundary -Namespace $ns -ErrorAction Stop
  $cc.CimClassProperties | ForEach-Object { Write-Output ('PROP: ' + $_.Name + ' type=' + $_.CimType + ' key=' + $_.IsKey) }
} catch { Write-Output ('SCHEMA_ERR=' + $_.Exception.Message) }
Write-Output 'CFG_DONE'
