# DECISIVE: client package content on DP + retry — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue
$ns = 'root\SMS\site_CAD'

Write-Output '=== 1. Content library check for CAD00003 ==='
$lib = 'C:\Program Files\Microsoft Configuration Manager\ContentLibrary\DataLib\CAD00003'
Write-Output ('  DATALIB_DIR=' + (Test-Path $lib))
if (Test-Path $lib) { Get-ChildItem $lib | Select-Object -First 5 -ExpandProperty Name | ForEach-Object { Write-Output ('    FILE: ' + $_) } }
$pkg = Get-WmiObject -Namespace $ns -Class SMS_PackageStatus -Filter "PackageID='CAD00003'" -ErrorAction SilentlyContinue
if ($pkg) { $pkg | ForEach-Object { Write-Output ('  PKG_STATUS: ' + $_.State + ' | ' + $_.Status + ' | ' + $_.DPName) } } else { Write-Output '  NO_PKG_STATUS' }

Write-Output '=== 2. Raw SMS_DistributionDPStatus for CAD00003 ==='
try {
  $d = Get-WmiObject -Namespace $ns -Class SMS_DistributionDPStatus -Filter "PackageID='CAD00003'" -ErrorAction SilentlyContinue
  if ($d) { $d | ForEach-Object { Write-Output ('  RAW: ' + ($_ | ConvertTo-Json -Compress -Depth 2)) } } else { Write-Output '  NO_ROW' }
} catch { Write-Output ('  ERR=' + $_.Exception.Message) }

Write-Output '=== 3. Force-distribute client package to mbr02 DP ==='
try {
  $dp = Get-CMDistributionPoint -SiteSystemServerName 'mbr02.range.local' -ErrorAction Stop | Select-Object -First 1
  if ($dp) {
    Write-Output ('  DP_OBJ: ' + $dp.ServerName)
    Start-CMContentDistribution -PackageId 'CAD00003' -DistributionPointName $dp.ServerName -ErrorAction Stop
    Write-Output '  CONTENT_DIST_STARTED'
  } else { Write-Output '  DP_NOT_FOUND_BY_NAME' }
} catch { Write-Output ('  DIST_ERR=' + $_.Exception.Message) }

Write-Output '=== 4. Wait 90s for distribution/MF cache + retry ccmsetup ==='
Start-Sleep -Seconds 90
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 2
Set-Content -Path 'C:\Windows\Temp\ccm_run.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_run.cmd' -PassThru -WindowStyle Hidden
Write-Output ('  LAUNCH_PID=' + $p.Id)
Start-Sleep -Seconds 30
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('  LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 4 | ForEach-Object { $t = $_; if ($t.Length -gt 140) { $t = $t.Substring(0,140) }; Write-Output ('  LOG: ' + $t) }
}
Write-Output 'DECISIVE_DONE'
