# List C:\Windows\Temp + C:\tmp on mbr02 for SCCM package / ccmclean — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
Write-Output '=== C:\Windows\Temp (SCCM-related) ==='
Get-ChildItem 'C:\Windows\Temp' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'sccm|ccm|configmgr|client|SMS|setup|msi' } | ForEach-Object { Write-Output ('  ' + $_.Name + ' | ' + $_.Length + ' | ' + $_.LastWriteTime) }
Write-Output '=== C:\Windows\Temp top-level count ==='
Write-Output ('  COUNT=' + @(Get-ChildItem 'C:\Windows\Temp' -ErrorAction SilentlyContinue).Count)
Write-Output '=== C:\tmp ==='
if (Test-Path 'C:\tmp') {
  Get-ChildItem 'C:\tmp' -ErrorAction SilentlyContinue | Select-Object -First 30 | ForEach-Object { Write-Output ('  ' + $_.Name + ' | ' + $_.Length + ' | ' + $_.LastWriteTime) }
} else { Write-Output '  NO_C_TMP' }
Write-Output '=== Search for ccmclean / client MSI anywhere shallow ==='
foreach ($root in @('C:\Windows\Temp','C:\tmp','C:\SCCM_Extracted','C:\SCCM_Prereqs','C:\')) {
  Get-ChildItem $root -Recurse -Depth 3 -Include 'ccmclean*','ccmsetup*','client.msi','SMSClient*.msi' -ErrorAction SilentlyContinue | Select-Object -First 10 | ForEach-Object { Write-Output ('  FOUND: ' + $_.FullName) }
}
Write-Output 'LIST_DONE'
