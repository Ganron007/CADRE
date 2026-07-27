#!/usr/bin/env bash
# Plan 1 per-attack verify helper — run on provisioning (.60)
# Usage: plan1-verify-attack.sh <CASE_ID> <ATTACK_ID> <SCRIPT> [SID]
set -euo pipefail
CASE_ID="${1:?}"
ATTACK_ID="${2:?}"
SCRIPT="${3:?}"
SID="${4:-}"
ES="http://elastic:elastic_CADRE_2026!@192.168.77.50:9200"
ATTACKS="/home/vagrant/attack-matrix/04-automation/linux/attacks"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== VERIFY ${CASE_ID} ${ATTACK_ID} T0=${T0} ==="
cd "$ATTACKS"
bash "./${SCRIPT}" || true
sleep 15
if [[ -n "$SID" ]]; then
  Q=$(cat <<EOF
{"size":0,"query":{"bool":{"must":[
  {"range":{"@timestamp":{"gte":"${T0}"}}},
  {"term":{"suricata.eve.alert.signature_id":${SID}}}
]}}}
EOF
)
  RESP=$(curl -s "$ES/logs-suricata.eve-*/_search" -H 'Content-Type: application/json' -d "$Q")
  HITS=$(echo "$RESP" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('hits',{}).get('total',{}).get('value',0))" 2>/dev/null || echo 0)
  echo "SURI_SID_${SID}=${HITS}"
fi
# Zeek notice count
ZQ='{"size":0,"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"now-15m"}}},{"term":{"source.ip":"192.168.77.60"}},{"exists":{"field":"zeek.notice.note"}}]}}}'
ZN=$(curl -s "$ES/logs-zeek.notice-*/_search" -H 'Content-Type: application/json' -d "$ZQ" | python3 -c "import json,sys; print(json.load(sys.stdin)['hits']['total']['value'])" 2>/dev/null || echo 0)
echo "ZEEK_NOTICE=${ZN}"
# Zeek dns
DQ='{"size":0,"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"now-15m"}}},{"term":{"source.ip":"192.168.77.60"}}]}}}'
ZD=$(curl -s "$ES/logs-zeek.dns-*/_search" -H 'Content-Type: application/json' -d "$DQ" | python3 -c "import json,sys; print(json.load(sys.stdin)['hits']['total']['value'])" 2>/dev/null || echo 0)
echo "ZEEK_DNS=${ZD}"
if [[ -x /home/vagrant/cadre-es-export.sh ]]; then
  CADRE_EXPORT_LOOKBACK_MIN=15 /home/vagrant/cadre-es-export.sh "$CASE_ID" "$ATTACK_ID" "$T0" >/dev/null 2>&1 || true
fi
echo "=== DONE ${CASE_ID} ==="
