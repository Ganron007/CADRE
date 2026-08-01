$ErrorActionPreference = "Continue"
Write-Output "=== ESC8 preflight (2026-08-01) ==="
$venv = "C:\Tools\RedStrike\.venv\Scripts"
$tools = @{
  "ntlmrelayx.py" = "$venv\ntlmrelayx.py"
  "coercer.exe"   = "$venv\coercer.exe"
  "certipy.exe"   = "$venv\certipy.exe"
  "MS-RPRN.exe"   = "C:\Tools\ADTools\MS-RPRN.exe"
}
foreach ($t in $tools.GetEnumerator()) {
  Write-Output ("{0}={1}" -f $t.Key, (Test-Path $t.Value))
}

Write-Output "=== port 8445 ==="
$c = Get-NetTCPConnection -LocalPort 8445 -State Listen -ErrorAction SilentlyContinue
Write-Output ("port8445_listening={0}" -f [bool]$c)

Write-Output "=== ADCS endpoint (anonymous) ==="
try {
  $r = Invoke-WebRequest "http://dc01.cadre.local/certsrv/certfnsh.asp" -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
  Write-Output ("certsrv={0}" -f $r.StatusCode)
} catch {
  Write-Output ("certsrv_ERR={0}" -f $_.Exception.Message)
}

Write-Output "=== chief_command LDAP bind ==="
try {
  $ldap = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc01.cadre.local/DC=cadre,DC=local", "cadre.local\chief_command", "C0mm@nd_Ch1ef!")
  $b = $ldap.psbase
  $b.RefreshCache()
  Write-Output "chief_bind=OK"
} catch {
  Write-Output ("chief_bind_ERR={0}" -f $_.Exception.Message)
}

Write-Output "=== spooler on DCs ==="
foreach ($dc in @("dc01","dc02","dc03")) {
  try {
    $svc = Get-Service Spooler -ComputerName $dc -ErrorAction SilentlyContinue
    Write-Output ("spooler_{0}={1}" -f $dc, $svc.Status)
  } catch {
    Write-Output ("spooler_{0}=ERR" -f $dc)
  }
}
Write-Output "=== PREFLIGHT_DONE ==="
