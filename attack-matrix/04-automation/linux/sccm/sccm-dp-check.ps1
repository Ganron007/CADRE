# DP + client package content distribution state — CONFIG, vagrant on mbr02
$ErrorActionPreference = 'Continue'
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -ErrorAction SilentlyContinue
Set-Location 'CAD:' -ErrorAction SilentlyContinue
Write-Output '=== Distribution points ==='
try {
  Get-CMDistributionPoint -ErrorAction Stop | ForEach-Object { Write-Output ('DP: ' + $_.NetworkOSPath + ' | ' + $_.ServerName + ' | PXE=' + $_.IsPXE + ' | ' + $_.RoleName) }
} catch { Write-Output ('DP_ERR=' + $_.Exception.Message) }
Write-Output '=== Client package (CAD00003) distribution status ==='
try {
  Get-CMContentDistributionStatus -PackageId 'CAD00003' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('CDS: ' + $_.PackageID + ' | ' + $_.Name + ' | ' + $_.State + ' | ' + $_.DistributionPointName) }
} catch { Write-Output ('CDS_ERR=' + $_.Exception.Message) }
Write-Output '=== Boundary group site systems (fixed display) ==='
try {
  $g = Get-CMBoundaryGroup -Name 'CADRE-Lab-BG' -ErrorAction SilentlyContinue
  if ($g) {
    $gss = Get-CMBoundaryGroupSiteSystem -BoundaryGroup $g -ErrorAction SilentlyContinue
    if ($gss) { $gss | ForEach-Object { Write-Output ('GSS_OBJ: ' + ($_ | ConvertTo-Json -Compress -Depth 2)) } } else { Write-Output 'GSS_EMPTY' }
  }
} catch { Write-Output ('GSS_ERR=' + $_.Exception.Message) }
Write-Output '=== Client package info ==='
try {
  Get-CMClientPackage -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('CP: ' + $_.PackageID + ' | ' + $_.Name + ' | version=' + $_.Version) }
} catch { Write-Output ('CP_ERR=' + $_.Exception.Message) }
Write-Output 'CHECK_DONE'
