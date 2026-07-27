# CADRE — WT091 — Data Staging
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT091 - Data Staging"
start_attack "091" "Data Staging"
step "Stage documents to staging directory"
run_cmd "New-Item -ItemType Directory -Path C:\Windows\Temp\staging -Force"
run_cmd "robocopy C:\Shares\public C:\Windows\Temp\staging *.txt *.csv /S /NP"
step "Compress for simulated exfiltration"
run_cmd "Compress-Archive -Path C:\Windows\Temp\staging\* -DestinationPath C:\Windows\Temp\exfil-ready.zip -Force"
step "Clean up"
run_cmd "Remove-Item C:\Windows\Temp\staging -Recurse -Force; Remove-Item C:\Windows\Temp\exfil-ready.zip -Force"
result 0 "WT091 — check Sysmon EID 11, Endpoint.events.file-*"
