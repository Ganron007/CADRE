#!/usr/bin/env bash
# Plan 1 attack orchestrator — run on provisioning (.60)
# Usage: plan1-orchestrator.sh <CASE_ID> <T_ATTACK> [--] <attack-command...>
# Records T0, runs command, waits for ingest, exports bundle, prints telemetry counts.

set -euo pipefail

CASE_ID="${1:?CASE_ID}"
T_ATTACK="${2:?T_ATTACK}"
shift 2
if [[ "${1:-}" == "--" ]]; then shift; fi
CMD=("$@")
if [[ ${#CMD[@]} -eq 0 ]]; then
  echo "usage: plan1-orchestrator.sh CASE_ID T_ATTACK -- command..." >&2
  exit 1
fi

ES_URL="${CADRE_ES_URL:-http://elastic:elastic_CADRE_2026!@192.168.77.50:9200}"
LOOKBACK="${CADRE_EXPORT_LOOKBACK_MIN:-15}"
SRC='{"term": {"source.ip": "192.168.77.60"}}'
WIN='{"range": {"@timestamp": {"gte": "now-'${LOOKBACK}'m", "lte": "now"}}}'
RESULTS="${CADRE_EVIDENCE_ROOT:-$HOME/cadre-evidence}/plan1-results.jsonl"

T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo ""
echo "========== PLAN1 RUN ${CASE_ID} ${T_ATTACK} T0=${T0} =========="
echo "CMD: ${CMD[*]}"

set +e
timeout "${CADRE_ATTACK_TIMEOUT_SEC:-180}" "${CMD[@]}"
RC=$?
set -e
echo "attack_exit=${RC}"

sleep "${CADRE_INGEST_WAIT_SEC:-50}"

EXPORT="${HOME}/cadre-es-export.sh"
if [[ -x "$EXPORT" ]]; then
  "$EXPORT" "$CASE_ID" "$T_ATTACK" "$T0" --lookback "$LOOKBACK" || true
else
  echo "WARN: cadre-es-export.sh missing" >&2
fi

es_count() {
  local idx="$1" extra="${2:-}" use_src="${3:-yes}"
  local must="[$WIN"
  if [[ "$use_src" == "yes" ]]; then must="$must,$SRC"; fi
  if [[ -n "$extra" ]]; then must="$must,$extra"; fi
  must="$must]"
  local q='{"query":{"bool":{"must":'"$must"'}}}'
  curl -s "${ES_URL}/${idx}/_count" -H 'Content-Type: application/json' -d "$q" \
    | jq -r '.count // 0' 2>/dev/null || echo 0
}

W4768=$(es_count 'logs-system.security-*' '{"term":{"winlog.event_id":4768}}')
W4769=$(es_count 'logs-system.security-*' '{"term":{"winlog.event_id":4769}}')
W4625=$(es_count 'logs-system.security-*' '{"term":{"winlog.event_id":4625}}')
W4771=$(es_count 'logs-system.security-*' '{"term":{"winlog.event_id":4771}}')
W4662=$(es_count 'logs-system.security-*' '{"term":{"winlog.event_id":4662}}')
W4738=$(es_count 'logs-system.security-*' '{"term":{"winlog.event_id":4738}}')
ZEK=$(es_count 'logs-zeek.kerberos-*' '' no)
ZDNS=$(es_count 'logs-zeek.dns-*' '' no)
SURI=$(es_count 'logs-suricata.eve-*' '{"exists":{"field":"suricata.eve.alert"}}' no)
ENDPT=$(es_count 'logs-endpoint.events.network-*')
SYSMON=$(es_count 'logs-windows.sysmon_operational-*' '' no)
AUDIT=$(es_count 'logs-auditd.log-*' '' no)

# WinSec often logs on DC — count without source.ip filter for domain events
es_count_winsec() {
  local eid="$1"
  local q='{"query":{"bool":{"must":['"$WIN"',{"term":{"winlog.event_id":'"$eid"'}}]}}}'
  curl -s "${ES_URL}/logs-system.security-*/_count" -H 'Content-Type: application/json' -d "$q" \
    | jq -r '.count // 0' 2>/dev/null || echo 0
}
W4768_DC=$(es_count_winsec 4768)
W4769_DC=$(es_count_winsec 4769)
W4625_DC=$(es_count_winsec 4625)
W4771_DC=$(es_count_winsec 4771)

LINE=$(jq -nc \
  --arg case_id "$CASE_ID" \
  --arg attack "$T_ATTACK" \
  --arg t0 "$T0" \
  --argjson rc "$RC" \
  --argjson w4768 "$W4768_DC" --argjson w4769 "$W4769_DC" \
  --argjson w4625 "$W4625_DC" --argjson w4771 "$W4771_DC" \
  --argjson w4662 "$W4662" --argjson w4738 "$W4738" \
  --argjson zek "$ZEK" --argjson zdns "$ZDNS" \
  --argjson suri "$SURI" --argjson endpt "$ENDPT" \
  --argjson sysmon "$SYSMON" --argjson audit "$AUDIT" \
  '{case_id:$case_id,attack:$attack,t0:$t0,rc:$rc,
    winsec:{e4768:$w4768,e4769:$w4769,e4625:$w4625,e4771:$w4771,e4662:$w4662,e4738:$w4738},
    zeek_kerberos:$zek,zeek_dns:$zdns,suricata_alerts:$suri,endpoint_net:$endpt,sysmon:$sysmon,auditd:$audit}')
echo "$LINE" | tee -a "$RESULTS"
echo "========== DONE ${CASE_ID} rc=${RC} =========="
exit 0
