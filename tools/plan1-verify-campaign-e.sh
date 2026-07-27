#!/usr/bin/env bash
# Plan 1 — Campaign E sequential verify (provisioning .60)
# Usage: bash ~/plan1-verify-campaign-e.sh
set -euo pipefail
VERIFY="${HOME}/plan1-verify-attack.sh"
[[ -x "$VERIFY" ]] || { echo "Missing $VERIFY"; exit 1; }

run_one() {
  local case_id="$1" eid="$2" script="$3" sid="${4:-}"
  echo ""
  echo "########## ${eid} ##########"
  if [[ -n "$sid" ]]; then
    "$VERIFY" "$case_id" "$eid" "$script" "$sid" || true
  else
    "$VERIFY" "$case_id" "$eid" "$script" || true
  fi
}

# E-01 .. E-06 DNS/TLS (cadre-phaseb SIDs)
run_one CADRE-E01-DGA-20260725      E-01 plan0.7-dns-dga.sh                 1000025
run_one CADRE-E02-TXT-20260725      E-02 plan0.7-dns-txt.sh                 1000026
run_one CADRE-E03-NXDOMAIN-20260725 E-03 plan0.7-dns-nxdomain-burst.sh       1000027
run_one CADRE-E04-TLD-20260725      E-04 plan0.7-dns-suspicious-tld.sh       1000028
run_one CADRE-E05-IPLIT-20260725    E-05 plan0.7-dns-ip-literal.sh          1000029
run_one CADRE-E06-TLS10-20260725    E-06 plan0.7-tls-v1.sh                  1000010

# E-07: grid marks deferred — still exercise script; SID 2000032 (ET lab rules)
run_one CADRE-E07-SNI-20260725      E-07 plan0.7-tls-sni-high-entropy.sh     2000032

# E-08 .. E-13 (ET lab SIDs)
run_one CADRE-E08-SMBADM-20260725   E-08 plan0.7-smb-admin-share.sh         2000012
run_one CADRE-E09-SMBV1-20260725    E-09 plan0.7-smb-v1.sh                  2000010
run_one CADRE-E10-HTTPUA-20260725   E-10 plan0.7-http-suspicious-ua.sh       2000041
run_one CADRE-E11-HTTPEXP-20260725  E-11 plan0.7-http-exploit-path.sh       2000070
run_one CADRE-E12-HTTPCNT-20260725  E-12 plan0.7-http-suspicious-content-type.sh 2000072
run_one CADRE-E13-SSHBF-20260725    E-13 plan0.7-ssh-bruteforce.sh          2000060

echo ""
echo "########## E-14 (Zeek notice — script holds ~300s; run separately) ##########"
echo "SKIP: plan0.7-long-connection.sh — use manual run or background job"

echo ""
echo "########## E-15 (outbound — no dedicated script; NAT external probe deferred) ##########"
echo "SKIP: no plan0.7-outbound.sh — mark deferred unless external dest available"

echo ""
echo "=== Campaign E batch complete ==="
