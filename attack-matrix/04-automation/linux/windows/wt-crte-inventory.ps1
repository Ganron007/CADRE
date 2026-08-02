# Inventory C:\Tools\CRTE_Tools (both copies) - recursive, dirs + files
$ErrorActionPreference = 'Continue'
$root = 'C:\Tools\CRTE_Tools'
if (-not (Test-Path $root)) { Write-Output "MISSING $root"; exit }
Write-Output "=== TOP LEVEL ==="
Get-ChildItem $root | Select-Object Mode, Name, Length | Format-Table -AutoSize | Out-String -Width 120 | Write-Output
Write-Output "=== ALL DIRS (2 levels) ==="
Get-ChildItem $root -Directory -Recurse -Depth 2 -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName.Replace($root, '') } | Out-String | Write-Output
Write-Output "=== ALL FILES ==="
Get-ChildItem $root -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
  $rel = $_.FullName.Replace($root, '')
  "{0,10}  {1}" -f $_.Length, $rel
} | Out-String -Width 200 | Write-Output
Write-Output "CRTE_INVENTORY_DONE"
