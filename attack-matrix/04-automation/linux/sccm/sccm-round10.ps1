# Round 10: use the SCCM console PowerShell module (official path) — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Write-Output '=== Locate ConfigurationManager module ==='
$mods = @(
  'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1',
  'C:\Program Files\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1',
  'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1',
  'C:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
)
$modPath = $null
foreach ($m in $mods) { if (Test-Path $m) { $modPath = $m; break } }
if (-not $modPath) {
  $found = Get-ChildItem 'C:\Program Files*\Microsoft*Configuration Manager*\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
  $modPath = $found
}
Write-Output ('MODULE=' + $modPath)
if (-not $modPath) { Write-Output 'NO_MODULE'; exit 1 }
try {
  Import-Module $modPath -ErrorAction Stop
  Write-Output 'MODULE_IMPORTED'
} catch { Write-Output ('IMPORT_ERR=' + $_.Exception.Message); exit 1 }
try {
  Set-Location 'CAD:' -ErrorAction Stop
  Write-Output ('LOCATION=' + (Get-Location).Path)
} catch { Write-Output ('LOC_ERR=' + $_.Exception.Message); exit 1 }
Write-Output '=== Boundary cmdlets available ==='
Get-Command -Name '*Boundary*' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('CMDLET: ' + $_.Name) }
Write-Output '=== Create boundary + group (idempotent) ==='
try {
  $b = Get-CMBoundary -BoundaryName 'CADRE-Lab-Subnet' -ErrorAction SilentlyContinue
  if (-not $b) {
    New-CMBoundary -DisplayName 'CADRE-Lab-Subnet' -Type IPSubnet -Value '192.168.77.0/24' -ErrorAction Stop | Out-Null
    Write-Output 'BOUNDARY_CREATED'
  } else { Write-Output 'BOUNDARY_EXISTS' }
} catch { Write-Output ('B_ERR=' + $_.Exception.Message) }
try {
  $g = Get-CMBoundaryGroup -Name 'CADRE-Lab-BG' -ErrorAction SilentlyContinue
  if (-not $g) {
    New-CMBoundaryGroup -Name 'CADRE-Lab-BG' -ErrorAction Stop | Out-Null
    Write-Output 'GROUP_CREATED'
  } else { Write-Output 'GROUP_EXISTS' }
} catch { Write-Output ('G_ERR=' + $_.Exception.Message) }
try {
  Add-CMBoundaryToGroup -BoundaryName 'CADRE-Lab-Subnet' -BoundaryGroupName 'CADRE-Lab-BG' -ErrorAction Stop
  Write-Output 'BOUNDARY_TO_GROUP_ADDED'
} catch { Write-Output ('B2G_ERR=' + $_.Exception.Message) }
Write-Output '=== Verify ==='
Get-CMBoundary -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('BOUNDARY: ' + $_.DisplayName + ' | ' + $_.Value) }
Get-CMBoundaryGroup -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('GROUP: ' + $_.Name) }
Write-Output 'CFG_DONE'
