#!/usr/bin/env bash
# Run remaining Campaign A attacks in spine order (T003 must already be ✅)
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
export CASE_DATE="${CASE_DATE:-$(date -u +%Y%m%d)}"

run() {
  echo ""
  echo "########################################"
  echo "# $1"
  echo "########################################"
  bash "$1" || echo "WARN: $1 exited $?"
}

# T031 + T003 assumed done
run "${DIR}/T002-kerb-ws01.sh"
run "${DIR}/T028-nullsession.sh"
run "${DIR}/T041-xpcmd-ws01.sh"
run "${DIR}/T043-impersonate-ws01.sh"
run "${DIR}/T009-dcsync-ws01.sh"
run "${DIR}/T010-golden-ws01.sh"
run "${DIR}/T011-silver-ws01.sh"
run "${DIR}/T012-diamond-ws01.sh"
run "${DIR}/T033-xforest-ws01.sh"
run "${DIR}/T042-clr-ws01.sh"

echo "=== Campaign A batch complete ==="
