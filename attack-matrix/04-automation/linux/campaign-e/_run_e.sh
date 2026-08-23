#!/bin/bash
# Plan 1.1 M5 thin wrapper — Campaign E: delegates to the actual Plan 0.7 attack script.
# Sourced by wt069-wt081. Must be a function: auto-run + exec used to skip the
# wrapper's `_run_e ...` line; without exec that line is `command not found` (127).
_run_e() {
  set -euo pipefail
  local RUN_HERE SCRIPT MAP TARGET NID
  RUN_HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  SCRIPT="$(basename "${1:-${BASH_SOURCE[1]}}")"

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
    *) echo "[-] Unknown wrapper: $SCRIPT" >&2; return 1 ;;
  esac

  TARGET="${RUN_HERE}/../attacks/plan0.7-${MAP}.sh"
  if [[ ! -f "$TARGET" ]]; then
    echo "[-] Missing target: $TARGET" >&2
    return 1
  fi
  (
    cd "$(dirname "$TARGET")"
    bash "$(basename "$TARGET")"
  )
  NID="$(echo "$SCRIPT" | grep -oE 'wt[0-9]+' | tr '[:lower:]' '[:upper:]')"
  echo "${NID}_OK"
}
