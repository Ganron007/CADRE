$ErrorActionPreference = 'Continue'
Write-Output "WHOAMI $(whoami)"
Write-Output "ELEVATED $(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))"
Write-Output "--- groups ---"
whoami /groups | Select-String 'S-1-5-32-544|S-1-5-32-551|S-1-5-32-555|Administrators|Backup' | ForEach-Object { Write-Output "GRP|$_" }
Write-Output "--- local admins ---"
net localgroup administrators | ForEach-Object { Write-Output "ADMIN|$_" }
