# CADRE — WT088 — Scheduled Task Persistence
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT088 - Scheduled Task Persistence"
start_attack "088" "Scheduled Task Persistence"
step "Create persistence scheduled task"
run_cmd "schtasks /create /tn 'CADRE-Persist' /tr 'powershell.exe -WindowStyle Hidden' /sc onlogon /ru SYSTEM /f"
step "Verify task exists"
run_cmd "schtasks /query /tn 'CADRE-Persist' /fo LIST /v"
step "Clean up"
run_cmd "schtasks /delete /tn 'CADRE-Persist' /f"
result 0 "WT088 — check 4698, Sysmon EID 1 (schtasks.exe)"
