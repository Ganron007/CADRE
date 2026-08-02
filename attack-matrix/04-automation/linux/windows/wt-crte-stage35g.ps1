# Locate 3.5G DPAPI artifacts + verify CRTE SharpDPAPI runs
$ErrorActionPreference = 'Continue'
Write-Output '=== search DPAPI artifacts (pvk/key/der/pfx/b64) ==='
Get-ChildItem C:\Tools -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'ntds_capi|ntds_legacy|wt035g|\.pvk$|backupkey' } | ForEach-Object {
  "{0,9}  {1}" -f $_.Length, $_.FullName
} | Out-String -Width 200 | Write-Output
Write-Output '=== CRTE SharpDPAPI version ==='
& 'C:\Tools\ADTools\CRTE-2026\SharpDPAPI.exe' 2>&1 | Select-Object -First 12 | ForEach-Object { Write-Output "SDPAPI|$_" }
Write-Output '=== PPLBlade presence ==='
Get-ChildItem 'C:\Tools\ADTools\CRTE-2026\PPLBlade' -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "PPL|$($_.Name)|$($_.Length)" }
Write-Output '3.5G_STAGE_DONE'
