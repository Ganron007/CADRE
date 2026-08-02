# Consolidate CRTE tools: merge unique/newer into ADTools\CRTE-2026, then remove CRTE_Tools duplicates
$ErrorActionPreference = 'Continue'
$src = 'C:\Tools\CRTE_Tools\Tools'
$dst = 'C:\Tools\ADTools\CRTE-2026'
New-Item -ItemType Directory -Force -Path $dst | Out-Null

# curated unique/newer files (top-level) to merge
$files = @(
  'SharpDPAPI.exe', 'Rubeus.exe', 'DefenderCheck.exe', 'DCOMRunAs.exe',
  'SharpGPOAbuse.exe', 'Keycred.exe', 'chromelevator_x64.exe',
  'SharpADWS.exe', 'SOAPHound.exe', 'Get-LAPSPermissions.ps1',
  'adddcsync.ps1', 'Invoke-EDRChecker.ps1', 'Find-WMILocalAdminAccess.ps1',
  'Find-PSRemotingLocalAdminAccess.ps1', 'Invoke-SDPropagator.ps1',
  'CIPolicyParser.ps1', 'hex2b64.ps1', 'ByteToLineNumber.ps1',
  'AmsiTrigger_x64.exe', 'NetLoader.exe', 'Whisker.exe', 'GoldenGMSA.exe',
  'MS-RPRN.exe', 'SharpWMI.exe', 'WSMan-WinRM.exe', 'SharpSuccessor.exe',
  'LeakedHandlesFinder.exe', 'AssemblyLoad.exe', 'DonutShellcodeLoader.exe',
  'Outflank-Dumpert.exe', 'mimispool.dll', 'VERSION.dll', 'RACE-master'
)
foreach ($f in $files) {
  $p = Join-Path $src $f
  if (Test-Path $p) {
    Copy-Item $p $dst -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output "MERGED $f"
  } else {
    Write-Output "SKIP(missing) $f"
  }
}

# small dirs to merge wholesale
$dirs = @('PPLBlade', 'EntraConnectAbuse', 'DSInternals_v5.3', 'InviShell', 'Powermad', 'mock')
foreach ($d in $dirs) {
  $p = Join-Path $src $d
  if (Test-Path $p) {
    Copy-Item $p $dst -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output "MERGED_DIR $d"
  }
}

# remove the duplicate CRTE_Tools tree (consolidated into ADTools\CRTE-2026)
Write-Output '--- removing C:\Tools\CRTE_Tools ---'
Remove-Item 'C:\Tools\CRTE_Tools' -Recurse -Force -ErrorAction SilentlyContinue
Write-Output "CRTE_Tools_exists $(Test-Path 'C:\Tools\CRTE_Tools')"

Write-Output '--- ADTools\CRTE-2026 final ---'
Get-ChildItem $dst -Force | Select-Object Mode, Name, Length | Format-Table -AutoSize | Out-String -Width 120 | Write-Output
Write-Output 'CONSOLIDATE_DONE'
