# ESC8 (WT052) v5 - diagnostic preconditions: firewall 8445/80, ADCS endpoint, chief_command creds
$ErrorActionPreference = "Continue"

Write-Output "=== firewall rules ==="
Get-NetFirewallRule | Where-Object { $_.DisplayName -match "ESC8|8445|CADRE" } | Select-Object DisplayName, Enabled, Action, Direction | Format-Table -AutoSize

Write-Output "=== port 8445 listen state ==="
Get-NetTCPConnection -LocalPort 8445 -State Listen -ErrorAction SilentlyContinue | Format-Table LocalAddress,LocalPort,OwningProcess -AutoSize
Write-Output "port8445_free=$(-not [bool](Get-NetTCPConnection -LocalPort 8445 -State Listen -ErrorAction SilentlyContinue))"

Write-Output "=== ADCS web enrollment endpoint (anonymous) ==="
try {
  $r = Invoke-WebRequest "http://dc01.cadre.local/certsrv/certfnsh.asp" -UseBasicParsing -TimeoutSec 10
  Write-Output ("certsrv_http=" + $r.StatusCode)
} catch {
  Write-Output ("certsrv_http_ERR=" + $_.Exception.Message)
}

Write-Output "=== chief_command credential check (LDAP bind) ==="
$ldap = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc01.cadre.local/DC=cadre,DC=local", "cadre.local\chief_command", "C0mm@nd_Ch1ef!")
try {
  $b = $ldap.psbase
  $b.RefreshCache()
  Write-Output "chief_bind=OK"
} catch {
  Write-Output "chief_bind_ERR=$($_.Exception.Message)"
}

Write-Output "=== SMB stack state (must NOT interfere with 8445) ==="
Get-Service LanmanServer,srv2,srvnet -ErrorAction SilentlyContinue | Format-Table Status,Name,StartType -AutoSize

Write-Output "=== relay tool versions ==="
$venv = "C:\Tools\RedStrike\.venv\Scripts"
if (Test-Path "$venv\ntlmrelayx.py") { Write-Output "ntlmrelayx=present" }
if (Test-Path "$venv\coercer.exe") { Write-Output "coercer=present" }
if (Test-Path "$venv\certipy.exe") { Write-Output "certipy=present" }
if (Test-Path "C:\Tools\ADTools\MS-RPRN.exe") { Write-Output "MS-RPRN.exe=present" }
