# Cleanup: kill stray relay, restore SMB services
$ErrorActionPreference = "Continue"
Get-Process python -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*Python312*" } | Format-Table Id,ProcessName -AutoSize
Stop-Process -Name python -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
sc.exe start srvnet | Out-Null
sc.exe start srv2 | Out-Null
Start-Sleep -Seconds 2
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Output "lanman=$( (Get-Service LanmanServer -ErrorAction SilentlyContinue).Status )"
Write-Output "srv2=$( (sc.exe query srv2 | Select-String STATE).ToString() )"
Write-Output "srvnet=$( (sc.exe query srvnet | Select-String STATE).ToString() )"
