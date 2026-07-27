#!/usr/bin/env bash
# Plan 1 — main AD campaign strict verify (provisioning .60)
# Usage: plan1-strict-ad.sh <CASE_ID> <T_ATTACK> <SCRIPT_BASENAME>
# Flow: run attack → ES samples per source → bundle → print counts for tracker paste
set -euo pipefail
CASE_ID="${1:?CASE_ID}"
T_ATTACK="${2:?T_ATTACK e.g. T009}"
SCRIPT="${3:?script e.g. WT009-dcsync.sh}"
ES="http://elastic:elastic_CADRE_2026!@192.168.77.50:9200"
ATTACKS="/home/vagrant/attack-matrix/04-automation/linux/attacks"
SRC='192.168.77.60'
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

es_count() {
  local idx="$1" q="$2"
  curl -s "$ES/${idx}/_search" -H 'Content-Type: application/json' -d "$q" \
    | python3 -c "import json,sys; d=json.load(sys.stdin); t=d.get('hits',{}).get('total',{}); print(t.get('value',t) if isinstance(t,dict) else t)"
}

es_sample() {
  local idx="$1" q="$2"
  curl -s "$ES/${idx}/_search" -H 'Content-Type: application/json' -d "$q" \
    | python3 -c "import json,sys; h=json.load(sys.stdin).get('hits',{}).get('hits',[]); print(json.dumps(h[0]['_source'],indent=2) if h else '')"
}

base_must=$(cat <<EOF
{"range":{"@timestamp":{"gte":"${T0}"}}},
{"term":{"source.ip":"${SRC}"}}
EOF
)

echo "=== STRICT AD ${T_ATTACK} CASE=${CASE_ID} T0=${T0} ==="
cd "$ATTACKS"
set +e
bash "./${SCRIPT}"
ATTACK_RC=$?
set -e
echo "ATTACK_RC=${ATTACK_RC}"
sleep 20

# WinSec (all + 4662 for DCSync)
WQ_ALL=$(cat <<EOF
{"size":1,"sort":[{"@timestamp":"desc"}],"query":{"bool":{"must":[${base_must}]}}}
EOF
)
WQ_4662=$(cat <<EOF
{"size":1,"sort":[{"@timestamp":"desc"}],"query":{"bool":{"must":[${base_must},{"term":{"winlog.event_id":"4662"}}]}}}
EOF
)
WQ_4768=$(cat <<EOF
{"size":1,"sort":[{"@timestamp":"desc"}],"query":{"bool":{"must":[${base_must},{"terms":{"winlog.event_id":["4768","4769","4771"]}}]}}}
EOF
)

C_WINSEC=$(es_count "logs-system.security-*" "$(echo "$WQ_ALL" | sed 's/"size":1/"size":0/')")
C_4662=$(es_count "logs-system.security-*" "$(echo "$WQ_4662" | sed 's/"size":1/"size":0/')")
C_SYSMON=$(es_count "logs-windows.sysmon_operational-*" "$(cat <<EOF
{"size":0,"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"source.ip":"${SRC}"}}]}}}
EOF
)")
C_ENDPT_P=$(es_count "logs-endpoint.events.process-*" "$(cat <<EOF
{"size":0,"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"source.ip":"${SRC}"}}]}}}
EOF
)")
C_ENDPT_N=$(es_count "logs-endpoint.events.network-*" "$(cat <<EOF
{"size":0,"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"source.ip":"${SRC}"}}]}}}
EOF
)")
C_ZK_K=$(es_count "logs-zeek.kerberos-*" "$(cat <<EOF
{"size":0,"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"source.ip":"${SRC}"}}]}}}
EOF
)")
C_ZK_D=$(es_count "logs-zeek.dce_rpc-*" "$(cat <<EOF
{"size":0,"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"source.ip":"${SRC}"}}]}}}
EOF
)")
C_SURI=$(es_count "logs-suricata.eve-*" "$(cat <<EOF
{"size":0,"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"exists":{"field":"suricata.eve.alert"}}]}}}
EOF
)")

echo "COUNTS WinSec=${C_WINSEC} WinSec4662=${C_4662} Sysmon=${C_SYSMON} EndptProc=${C_ENDPT_P} EndptNet=${C_ENDPT_N} ZeekKerb=${C_ZK_K} ZeekDCE=${C_ZK_D} Suri=${C_SURI}"

OUT="${HOME}/cadre-evidence/${CASE_ID}/samples"
mkdir -p "$OUT"
es_sample "logs-system.security-*" "$WQ_4662" > "${OUT}/winsec-4662-sample.json" || true
if [[ ! -s "${OUT}/winsec-4662-sample.json" ]]; then
  es_sample "logs-system.security-*" "$WQ_ALL" > "${OUT}/winsec-sample.json" || true
fi
es_sample "logs-zeek.kerberos-*" "$(cat <<EOF
{"size":1,"sort":[{"@timestamp":"desc"}],"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"source.ip":"${SRC}"}}]}}}
EOF
)" > "${OUT}/zeek-kerberos-sample.json" || true
es_sample "logs-zeek.dce_rpc-*" "$(cat <<EOF
{"size":1,"sort":[{"@timestamp":"desc"}],"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"source.ip":"${SRC}"}}]}}}
EOF
)" > "${OUT}/zeek-dce_rpc-sample.json" || true
es_sample "logs-endpoint.events.process-*" "$(cat <<EOF
{"size":1,"sort":[{"@timestamp":"desc"}],"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"source.ip":"${SRC}"}}]}}}
EOF
)" > "${OUT}/endpoint-process-sample.json" || true
es_sample "logs-suricata.eve-*" "$(cat <<EOF
{"size":1,"sort":[{"@timestamp":"desc"}],"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"exists":{"field":"suricata.eve.alert"}}]}}}
EOF
)" > "${OUT}/suricata-sample.json" || true

if [[ -x "${HOME}/cadre-es-export.sh" ]]; then
  CADRE_EXPORT_LOOKBACK_MIN=20 "${HOME}/cadre-es-export.sh" "$CASE_ID" "$T_ATTACK" "$T0" || true
fi

echo "=== DONE ${CASE_ID} samples in ${OUT} ==="
ls -la "$OUT" 2>/dev/null || true
