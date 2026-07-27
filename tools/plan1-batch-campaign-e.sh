#!/usr/bin/env bash
# Plan 1 — Campaign E (network defense) batch from provisioning
# Maps plan0.7-* scripts in linux/attacks to E-01..E-15 grid rows.
set -euo pipefail

AUTO="${CADRE_AUTO_ROOT:-$HOME/attack-matrix/04-automation/linux}"
ORCH="${CADRE_ORCH:-$HOME/plan1-orchestrator.sh}"
ATTACKS="${AUTO}/attacks"
DATE=$(date -u +%Y%m%d-%H%M)

sed -i 's/\r$//' "${AUTO}/lib/"*.sh "${ATTACKS}/"*.sh 2>/dev/null || true

run_script() {
  local case_id="$1" t="$2" script="$3"
  local base
  base=$(basename "$script")
  bash "$ORCH" "$case_id" "$t" -- bash -c "cd '${ATTACKS}' && bash './${base}'"
}

run_script "CADRE-E01-DGA-${DATE}" "E-01" "${ATTACKS}/plan0.7-dns-dga.sh"
run_script "CADRE-E02-TXT-${DATE}" "E-02" "${ATTACKS}/plan0.7-dns-txt.sh"
run_script "CADRE-E03-NXDOMAIN-${DATE}" "E-03" "${ATTACKS}/plan0.7-dns-nxdomain-burst.sh"
run_script "CADRE-E04-TLD-${DATE}" "E-04" "${ATTACKS}/plan0.7-dns-suspicious-tld.sh"
run_script "CADRE-E05-IPLIT-${DATE}" "E-05" "${ATTACKS}/plan0.7-dns-ip-literal.sh"
run_script "CADRE-E06-TLS10-${DATE}" "E-06" "${ATTACKS}/plan0.7-tls-v1.sh"
run_script "CADRE-E07-SNI-${DATE}" "E-07" "${ATTACKS}/plan0.7-tls-sni-high-entropy.sh"
run_script "CADRE-E08-SMBADM-${DATE}" "E-08" "${ATTACKS}/plan0.7-smb-admin-share.sh"
run_script "CADRE-E09-SMBV1-${DATE}" "E-09" "${ATTACKS}/plan0.7-smb-v1.sh"
run_script "CADRE-E10-HTTPUA-${DATE}" "E-10" "${ATTACKS}/plan0.7-http-suspicious-ua.sh"
run_script "CADRE-E11-HTTPEXP-${DATE}" "E-11" "${ATTACKS}/plan0.7-http-exploit-path.sh"
run_script "CADRE-E12-HTTPCNT-${DATE}" "E-12" "${ATTACKS}/plan0.7-http-suspicious-content-type.sh"
run_script "CADRE-E13-SSHBRUTE-${DATE}" "E-13" "${ATTACKS}/plan0.7-ssh-bruteforce.sh"
run_script "CADRE-E14-LONGCONN-${DATE}" "E-14" "${ATTACKS}/plan0.7-long-connection.sh"
bash "$ORCH" "CADRE-E15-OUTBOUND-${DATE}" "E-15" -- bash -c 'for u in https://example.com https://1.1.1.1; do curl -sS -m3 "$u" >/dev/null || true; done'

echo "Campaign E batch complete. Results: ~/cadre-evidence/plan1-results.jsonl"
