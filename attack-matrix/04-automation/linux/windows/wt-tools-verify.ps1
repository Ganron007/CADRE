# verify folder rename + confirm merged content present
$ErrorActionPreference = 'Continue'
Write-Output "CRTE-2026 exists: $(Test-Path 'C:\Tools\ADTools\CRTE-2026')"
Write-Output "tools-2026 exists: $(Test-Path 'C:\Tools\ADTools\tools-2026')"
if (Test-Path 'C:\Tools\ADTools\tools-2026') {
  Get-ChildItem 'C:\Tools\ADTools\tools-2026' -File | Select-Object -First 8 | ForEach-Object { Write-Output "TOOL $($_.Name) $($_.Length)" }
}
Write-Output 'VERIFY_DONE'
