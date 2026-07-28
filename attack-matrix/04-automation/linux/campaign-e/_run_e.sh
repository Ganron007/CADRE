#!/bin/bash
# Plan 1.1 M5 thin wrapper — Campaign E: delegates to the actual Plan 0.7 attack script.
set -euo pipefail
RUN_HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$(basename "${BASH_SOURCE[1]}")"

case "$SCRIPT" in
  wt069-dns-dga.sh)          MAP="dns-dga" ;;
  wt070-dns-txt.sh)          MAP="dns-txt" ;;
  wt071-dns-nxdomain.sh)     MAP="dns-nxdomain-burst" ;;
  wt072-dns-tld.sh)          MAP="dns-suspicious-tld" ;;
  wt073-dns-ip-literal.sh)   MAP="dns-ip-literal" ;;
  wt074-tls-v1.sh)           MAP="tls-v1" ;;
  wt075-smb-admin.sh)        MAP="smb-admin-share" ;;
  wt076-http-ua.sh)          MAP="http-suspicious-ua" ;;
  wt077-http-exploit-path.sh) MAP="http-exploit-path" ;;
  wt078-http-content-type.sh) MAP="http-suspicious-content-type" ;;
  wt079-ssh-brute.sh)        MAP="ssh-bruteforce" ;;
  wt080-long-connection.sh)  MAP="long-connection" ;;
  wt081-outbound-anomaly.sh) MAP="cross-subnet" ;;
  *) echo "[-] Unknown wrapper: $SCRIPT" >&2; exit 1 ;;
esac

TARGET="${RUN_HERE}/../attacks/plan0.7-${MAP}.sh"
if [[ ! -f "$TARGET" ]]; then
  echo "[-] Missing target: $TARGET" >&2
  exit 1
fi
cd "$(dirname "$TARGET")"
exec bash "$(basename "$TARGET")"
