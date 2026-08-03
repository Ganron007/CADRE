#!/usr/bin/env bash
# H-ASSUME — verify ws01 beachhead SSH (analyst_t1) before assume-breach spine.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== H-ASSUME beachhead check ==="
OUT=$(ws01_exec_as analyst_t1 'T13r_An@lyst!' 'whoami; hostname' 'child.cadre.local')
echo "${OUT}"
echo "${OUT}" | grep -qi analyst_t1
echo "H_ASSUME_OK"
