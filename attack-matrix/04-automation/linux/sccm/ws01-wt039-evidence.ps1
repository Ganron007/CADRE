Write-Output '=== wt039 marker files on WS01 ==='
if (Test-Path 'C:\Windows\Temp\wt039-system.txt') { Write-Output '--- wt039-system.txt ---'; Get-Content 'C:\Windows\Temp\wt039-system.txt' -ErrorAction SilentlyContinue }
if (Test-Path 'C:\Windows\Temp\wt039-marker.txt') { Write-Output '--- wt039-marker.txt ---'; Get-Content 'C:\Windows\Temp\wt039-marker.txt' -ErrorAction SilentlyContinue }
if (-not (Test-Path 'C:\Windows\Temp\wt039-system.txt') -and -not (Test-Path 'C:\Windows\Temp\wt039-marker.txt')) { Write-Output 'marker files not visible (ACL) — ScriptOutput is the evidence' }
Write-Output 'EVIDENCE_DONE'
