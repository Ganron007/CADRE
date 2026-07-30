#!/usr/bin/env bash
set -uo pipefail
RUN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"
LOG="$RUN/results.log"
rm -f "$LOG"

timeout_run() {
  local script="$1"
  local t="$2"
  echo "--- START $script ---" >> "$LOG"
  local start end rc
  start=$(date +%s)
  timeout "$t" bash "$RUN/campaign-a/$script" >> "$LOG" 2>&1
  rc=$?
  end=$(date +%s)
  if [[ $rc -eq 124 ]]; then echo "--- END $script TIMEOUT ---" >> "$LOG"; else echo "--- END $script RC=$rc ---" >> "$LOG"; fi
  printf '%s\t%s\t%s\t%s\n' "$(date -Iseconds)" "$script" "$rc" "$((end-start))" >> "$RUN/summary.tsv"
}

find "$RUN" -type f \( -name "*.sh" -o -name "*.ps1" \) -exec sed -i 's/\r$//' {} +

cd "$RUN/campaign-a"

for s in T041-xpcmd-ws01.sh T042-clr-ws01.sh T043-lpe-alternatives-ws01.sh T043-impersonate-ws01.sh T035-mbr01-creds-ws01.sh T035A-winlogon-creds-ws01.sh T101-winrs-pivot-ws01.sh T101a-trustedhosts-ws01.sh T007-rbcd-ws01.sh T009-dcsync-ws01.sh T010-golden-ws01.sh T011-silver-ws01.sh T012-diamond-ws01.sh T013-acl-writedacl-ws01.sh T014-acl-genericwrite-ws01.sh T016-acl-genericall-ou-ws01.sh T023-gpo-abuse-ws01.sh T024-gmsa-extraction-ws01.sh T008-shadow-credentials-ws01.sh T050-esc1-ws01.sh T051-esc3-ws01.sh T052-esc8-ws01.sh T053-unpac-thehash-ws01.sh T034-sccm-enum-ws01.sh T035-sccm-pxe-boot-ws01.sh T036-sccm-client-push-ws01.sh T037-sccm-cmpivot-ws01.sh T038-sccm-app-deploy-ws01.sh T039-sccm-site-takeover-ws01.sh T040-mssql-linked-server-hop-ws01.sh T102-coerce-dc02-ws01.sh T102-coerce-from-mbr01.sh; do
  if [[ -f "$s" ]]; then
    timeout_run "$s" 120
  else
    echo "MISSING $s" >> "$LOG"
    printf '%s\t%s\t%s\t%s\n' "$(date -Iseconds)" "$s" "missing" "0" >> "$RUN/summary.tsv"
  fi
done

echo "=== SUMMARY ===" >> "$LOG"
cat "$RUN/summary.tsv" >> "$LOG"
