# Add firewall allow rules for ESC8 (445 SMB + 80 HTTP) on ws01
$ErrorActionPreference = "Continue"
foreach ($port in 445,80) {
  $name = "ESC8-Allow-$port"
  if (-not (Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $name -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -Profile Any | Out-Null
    Write-Output "created_$name"
  } else {
    Write-Output "exists_$name"
  }
}
Write-Output "=== verify ==="
Get-NetFirewallRule -DisplayName "ESC8-*" | Format-Table DisplayName,Direction,Action,Enabled,Profile -AutoSize
