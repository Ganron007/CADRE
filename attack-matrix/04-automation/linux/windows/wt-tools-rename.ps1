# rename CRTE-2026 -> tools-2026 (neutral name, no course reference)
$ErrorActionPreference = 'Continue'
$old = 'C:\Tools\ADTools\CRTE-2026'
$new = 'C:\Tools\ADTools\tools-2026'
if (Test-Path $old) {
  Rename-Item $old $new -Force -ErrorAction Stop
  Write-Output "RENAMED_OK old=$(-not (Test-Path $old)) new=$(Test-Path $new)"
} else {
  Write-Output "NO_OLD existing=$(Test-Path $new)"
}
Get-ChildItem $new -File -ErrorAction SilentlyContinue | Select-Object -First 5 | ForEach-Object { Write-Output "TOOL $($_.Name)" }
Write-Output 'RENAME_DONE'
