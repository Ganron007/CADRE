# Check mbr02 NICs (which IP the client uses) + refresh MP + retry — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Write-Output '=== 1. mbr02 NICs ==='
Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -ne '127.0.0.1' } | ForEach-Object {
  Write-Output ('  NIC: ' + $_.InterfaceAlias + ' | ' + $_.IPAddress + '/' + $_.PrefixLength)
}
Write-Output '=== 2. Default route / which NIC leads to MP ==='
Get-NetRoute -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' -or $_.DestinationPrefix -eq '192.168.77.0/24' } | ForEach-Object {
  Write-Output ('  ROUTE: ' + $_.DestinationPrefix + ' via ' + $_.NextHop + ' ifIndex=' + $_.ifIndex)
}

Write-Output '=== 3. Restart SMS_EXECUTIVE to refresh MP boundary cache ==='
try {
  Restart-Service -Name SMS_EXECUTIVE -Force -ErrorAction Stop
  Write-Output '  SMS_EXECUTIVE_RESTARTED'
} catch { Write-Output ('  RESTART_ERR=' + $_.Exception.Message) }
Start-Sleep -Seconds 120
$s = Get-Service SMS_EXECUTIVE -ErrorAction SilentlyContinue
Write-Output ('  SMS_EXECUTIVE_STATE=' + $s.Status)
$rp = 'C:\Program Files\Microsoft Configuration Manager\logs\SMS_REST_PROVIDER.log'
if (Test-Path $rp) { Write-Output ('  RESTPROV_LAST=' + (Get-Item $rp).LastWriteTime) }

Write-Output '=== 4. Retry ccmsetup after MP refresh ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 2
Set-Content -Path 'C:\Windows\Temp\ccm_run.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_run.cmd' -PassThru -WindowStyle Hidden
Write-Output ('  PID=' + $p.Id)
Start-Sleep -Seconds 45
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('  LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 4 | ForEach-Object { $t = $_; if ($t.Length -gt 150) { $t = $t.Substring(0,150) }; Write-Output ('  ' + $t) }
}
Write-Output 'NIC_REFRESH_DONE'
