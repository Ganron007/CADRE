# Show full backupkeys output
$ErrorActionPreference = 'Continue'
Get-Content 'C:\Tools\ADTools\wt035g-backupkeys-full.txt' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "BK|$_" }
Write-Output '---END---'
