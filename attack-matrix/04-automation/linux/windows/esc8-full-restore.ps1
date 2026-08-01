# Full restore of SMB stack (handles disabled start types)
$ErrorActionPreference = "Continue"
Write-Output "=== restore start types ==="
sc.exe config LanmanServer start= auto
sc.exe config srv2 start= demand
sc.exe config srvnet start= demand
Write-Output "=== start stack ==="
sc.exe start srvnet
sc.exe start srv2
Start-Sleep -Seconds 2
Start-Service LanmanServer -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Output "lanman=$( (Get-Service LanmanServer -ErrorAction SilentlyContinue).Status )"
sc.exe query srv2 | Select-String STATE
sc.exe query srvnet | Select-String STATE
