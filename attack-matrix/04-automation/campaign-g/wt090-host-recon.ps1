# CADRE — WT090 — Host Reconnaissance
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT090 - Host Reconnaissance"
start_attack "090" "Host Reconnaissance"
step "System information"
run_cmd "systeminfo | findstr /B /C:'OS Name' /C:'OS Version' /C:'System Type'"
step "Network configuration"
run_cmd "ipconfig /all"
step "Current user context"
run_cmd "whoami /all"
step "Domain group enumeration"
run_cmd "net group 'Domain Admins' /domain"
run_cmd "net localgroup Administrators"
result 0 "WT090 — check Sysmon EID 1, 4688 for each command"
