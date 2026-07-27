# CADRE — WT065 — CHM Execution
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT065 - CHM Execution"
start_attack "065" "CHM Execution"
step "Requires HTML Help Workshop"
run_cmd "Write-Host 'CHM build steps:'"
run_cmd "Write-Host '  1. Create HTML file with <OBJECT> tag calling VBScript'"
run_cmd "Write-Host '  2. Compile with HTML Help Workshop (hhc.exe)'"
run_cmd "Write-Host '  3. Host on provisioning VM :8081'"
run_cmd "Write-Host '  4. Victim opens .chm -> hh.exe -> embedded script executes'"
step "Check hh.exe availability"
run_cmd "Get-Command hh.exe -ErrorAction SilentlyContinue | Select-Object Source"
result 0 "WT065 — check Sysmon EID 1 (hh.exe -> cmd/powershell)"
