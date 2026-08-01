# Add NAT subnet boundary + retry client — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue

Write-Output '=== 1. Add NAT subnet boundary (192.168.90.0/24) ==='
try {
  $b = Get-CMBoundary -BoundaryName 'CADRE-NAT-Subnet' -ErrorAction SilentlyContinue
  if (-not $b) {
    New-CMBoundary -DisplayName 'CADRE-NAT-Subnet' -Type IPSubnet -Value '192.168.90.0/24' -ErrorAction Stop | Out-Null
    Write-Output '  BOUNDARY_CREATED'
  } else { Write-Output '  BOUNDARY_EXISTS' }
} catch { Write-Output ('  B_ERR=' + $_.Exception.Message) }
try {
  Add-CMBoundaryToGroup -BoundaryName 'CADRE-NAT-Subnet' -BoundaryGroupName 'CADRE-Lab-BG' -ErrorAction Stop
  Write-Output '  ADDED_TO_GROUP'
} catch { Write-Output ('  A2G_ERR=' + $_.Exception.Message) }

Write-Output '=== 2. Verify group boundaries ==='
$g = Get-CMBoundaryGroup -Name 'CADRE-Lab-BG' -ErrorAction SilentlyContinue
Get-CMBoundary -BoundaryGroup $g -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('  IN_GROUP: ' + $_.DisplayName + ' | ' + $_.Value) }

Write-Output '=== 3. Retry ccmsetup ==='
taskkill /F /IM ccmsetup.exe 2>&1 | Out-Null
Start-Sleep -Seconds 2
Set-Content -Path 'C:\Windows\Temp\ccm_run.cmd' -Value 'C:\Windows\CCMSetup\ccmsetup.exe /MP:mbr02.range.local /SMSSITECODE=CAD /NoCRLCheck' -Encoding ascii
$p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c C:\Windows\Temp\ccm_run.cmd' -PassThru -WindowStyle Hidden
Write-Output ('  PID=' + $p.Id)
Start-Sleep -Seconds 45
$log = 'C:\Windows\CCMSetup\Logs\ccmsetup.log'
if (Test-Path $log) {
  Write-Output ('  LOG_LAST=' + (Get-Item $log).LastWriteTime)
  Get-Content $log -Tail 5 | ForEach-Object { $t = $_; if ($t.Length -gt 150) { $t = $t.Substring(0,150) }; Write-Output ('  ' + $t) }
}
Write-Output 'NAT_BOUNDARY_DONE'
