# Compact top-level inventory of CRTE_Tools
$ErrorActionPreference = 'Continue'
$root = 'C:\Tools\CRTE_Tools'
Write-Output '=== TOP-LEVEL (dir + file counts per child) ==='
Get-ChildItem $root -Force -ErrorAction SilentlyContinue | ForEach-Object {
  if ($_.PSIsContainer) {
    $n = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
    "DIR   {0,-30} {1} files" -f $_.Name, $n
  } else {
    "FILE  {0,-30} {1} bytes" -f $_.Name, $_.Length
  }
}
Write-Output ''
Write-Output '=== KEY BINARIES (exe/dll/ps1/py at depth<=3) ==='
Get-ChildItem $root -Recurse -Depth 3 -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(exe|dll|ps1|py|bat|cmd)$' } | ForEach-Object {
  $rel = $_.FullName.Replace($root, '')
  "{0,9}  {1}" -f $_.Length, $rel
} | Sort-Object | Out-String -Width 220 | Write-Output
Write-Output 'CRTE_TOP_DONE'
