# CADRE — WT089 — Registry Run Key Persistence
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT089 - Registry Run Key Persistence"
start_attack "089" "Registry Run Key Persistence"
step "Add Run key (HKLM — requires admin)"
run_cmd "reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Run' /v CADREBackdoor /t REG_SZ /d 'powershell.exe -WindowStyle Hidden' /f"
step "Verify"
run_cmd "Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -Name CADREBackdoor"
step "Clean up"
run_cmd "Remove-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' -Name CADREBackdoor"
result 0 "WT089 — check Sysmon EID 12-13, 4657, Endpoint.events.registry-*"
