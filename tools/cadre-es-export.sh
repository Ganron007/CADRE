#!/usr/bin/env bash
# CADRE evidence bundle exporter — run on provisioning (.60)
# Usage: cadre-es-export.sh <CASE_ID> <T_ATTACK> <T0_ISO> [T1_ISO] [--lookback MINUTES]
# T1 defaults to now (UTC). Queries use [T0 - lookback_pad, T1 + ingest_pad] — Fleet ingest lags ~15–60s.
# Example:
#   T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
#   ... run attack ...
#   cadre-es-export.sh CADRE-T003-ASREP T003 "$T0"

set -euo pipefail

CASE_ID="${1:?CASE_ID required}"
T_ATTACK="${2:?T_ATTACK required (e.g. T003)}"
T0="${3:?T0 ISO8601 required}"
T1="${4:-}"
LOOKBACK_MIN="${CADRE_EXPORT_LOOKBACK_MIN:-15}"
# Attack egress IP: ws01 beachhead (.62) for Phase 0.5+; provisioning (.60) for Phase 0 external only
ATTACK_SOURCE_IP="${CADRE_ATTACK_SOURCE_IP:-192.168.77.62}"

if [[ "${T1}" == "--lookback" ]] || [[ -z "${T1}" ]]; then
  T1=$(date -u +%Y-%m-%dT%H:%M:%SZ)
elif [[ "${5:-}" == "--lookback" ]]; then
  LOOKBACK_MIN="${6:-15}"
fi

ES_URL="${CADRE_ES_URL:-http://elastic:elastic_CADRE_2026!@192.168.77.50:9200}"
BASE="${CADRE_EVIDENCE_ROOT:-$HOME/cadre-evidence}"
OUT="${BASE}/${CASE_ID}"
ELASTIC_DIR="${OUT}/elastic"
mkdir -p "$ELASTIC_DIR"

es_search() {
  local name="$1"
  local index="$2"
  local query="$3"
  local file="${ELASTIC_DIR}/${name}.json"
  curl -s "${ES_URL}/${index}/_search" \
    -H 'Content-Type: application/json' \
    -d "$query" > "$file"
  local total
  total=$(jq -r '.hits.total.value // .hits.total // 0' "$file" 2>/dev/null || echo 0)
  echo "  ${name}: ${total} hits -> elastic/${name}.json"
}

# Relative window from attack start — avoids missing docs due to ingest lag
WINDOW='{"range": {"@timestamp": {"gte": "now-'${LOOKBACK_MIN}'m", "lte": "now"}}}'
SOURCE_FILTER='{"term": {"source.ip": "'"${ATTACK_SOURCE_IP}"'"}}'

echo "=== CADRE evidence export: ${CASE_ID} ==="
echo "Attack: ${T_ATTACK}  attack_T0=${T0}  export_T1=${T1}  lookback=${LOOKBACK_MIN}m"
echo "Output: ${OUT}"

# WinSec — Kerberos + password reset
es_search "winsec-4768-4769" "logs-system.security-*" "$(cat <<EOF
{"size": 20, "sort": [{"@timestamp": "desc"}],
 "query": {"bool": {"must": [
   ${WINDOW},
   {"terms": {"winlog.event_id": ["4768", "4769", "4738"]}},
   ${SOURCE_FILTER}
 ]}}}
EOF
)"

# Sysmon — attacker source IP in network events if present
es_search "sysmon" "logs-windows.sysmon_operational-*" "$(cat <<EOF
{"size": 20, "sort": [{"@timestamp": "desc"}],
 "query": {"bool": {"must": [ ${WINDOW} ]}}}
EOF
)"

# Endpoint network from Kali
es_search "endpoint-network" "logs-endpoint.events.network-*" "$(cat <<EOF
{"size": 20, "sort": [{"@timestamp": "desc"}],
 "query": {"bool": {"must": [ ${WINDOW}, ${SOURCE_FILTER} ]}}}
EOF
)"

# Zeek kerberos
es_search "zeek-kerberos" "logs-zeek.kerberos-*" "$(cat <<EOF
{"size": 20, "sort": [{"@timestamp": "desc"}],
 "query": {"bool": {"must": [ ${WINDOW}, ${SOURCE_FILTER} ]}}}
EOF
)"

# Suricata alerts
es_search "suricata-alerts" "logs-suricata.eve-*" "$(cat <<EOF
{"size": 20, "sort": [{"@timestamp": "desc"}],
 "query": {"bool": {"must": [
   ${WINDOW},
   {"exists": {"field": "suricata.eve.alert"}},
   ${SOURCE_FILTER}
 ]}}}
EOF
)"

cat > "${OUT}/manifest.json" <<EOF
{
  "case_id": "${CASE_ID}",
  "attack_id": "${T_ATTACK}",
  "t0": "${T0}",
  "t1": "${T1}",
  "lookback_minutes": ${LOOKBACK_MIN},
  "source_host": "${ATTACK_SOURCE_IP}",
  "elasticsearch": "192.168.77.50:9200",
  "exported_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "elastic_queries": [
    "winsec-4768-4769",
    "sysmon",
    "endpoint-network",
    "zeek-kerberos",
    "suricata-alerts"
  ],
  "dfir_nexus_case_suggestion": "${CASE_ID}"
}
EOF

cat > "${OUT}/notes.txt" <<EOF
UTC attack start: ${T0}
UTC export end:   ${T1}
Lookback:         ${LOOKBACK_MIN} minutes
Attack:           ${T_ATTACK}
Exporter:         cadre-es-export.sh on provisioning
EOF

echo "=== Done: ${OUT} ==="
ls -la "$OUT" "$ELASTIC_DIR"
