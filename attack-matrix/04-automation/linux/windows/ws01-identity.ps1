# ws01 identity + test spooler callback with FQDN UNC
$ErrorActionPreference = "Continue"
Write-Output "=== ws01 identity ==="
hostname
echo "USERDOMAIN=$env:USERDOMAIN"
$env:COMPUTERNAME
$fqdn = [System.Net.Dns]::GetHostEntry($env:COMPUTERNAME).HostName
Write-Output "FQDN=$fqdn"
ipconfig | Select-String "IPv4|Host Name" | ForEach-Object { $_.Line.Trim() }
Write-Output "=== current user ==="
whoami
