# Patch krbrelayx on ws01: HTTP-only relay (SMB 445 held by kernel PID 4)
$path = "C:\Tools\krbrelayx\krbrelayx.py"
$content = Get-Content $path -Raw
$old = "RELAY_SERVERS = ( SMBRelayServer, HTTPKrbRelayServer, DNSRelayServer )"
$new = "RELAY_SERVERS = ( HTTPKrbRelayServer, )"
if ($content -notmatch "HTTPKrbRelayServer, \)") {
  $content = $content.Replace($old, $new)
  Set-Content -Path $path -Value $content -NoNewline
  Write-Output "PATCHED"
} else {
  Write-Output "ALREADY_PATCHED"
}
