# Check SMB service failure/recovery config + what restarts them
$ErrorActionPreference = "Continue"
Write-Output "=== LanmanServer failure config ==="
sc.exe qfailure LanmanServer
Write-Output "=== srv2 failure config ==="
sc.exe qfailure srv2
Write-Output "=== srvnet failure config ==="
sc.exe qfailure srvnet
Write-Output "=== LanmanServer start type ==="
sc.exe qc LanmanServer | Select-String START_TYPE
Write-Output "=== srv2 start type ==="
sc.exe qc srv2 | Select-String START_TYPE
