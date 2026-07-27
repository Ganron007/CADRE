#!/usr/bin/env bash
# Run on provisioning .60 — T010 attack + ES sample pull
set -euo pipefail
CASE_ID="${1:-CADRE-T010-GOLDEN-20260725}"
ATTACKS="/home/vagrant/attack-matrix/04-automation/linux/attacks"
ES="http://elastic:elastic_CADRE_2026!@192.168.77.50:9200"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "T0=$T0 CASE=$CASE_ID"

cd "$ATTACKS"
bash ./WT010-golden-ticket.sh | tee "/tmp/${CASE_ID}.log"
sleep 25

OUT="${HOME}/cadre-evidence/${CASE_ID}/samples"
mkdir -p "$OUT"

query_winsec() {
  curl -s "${ES}/logs-system.security-*/_search" -H 'Content-Type: application/json' -d "$1"
}

WQ4769=$(cat <<EOF
{"size":1,"sort":[{"@timestamp":"desc"}],"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"host.name":"dc01"}},{"term":{"winlog.event_id":"4769"}},{"term":{"source.ip":"192.168.77.60"}}]}}}
EOF
)
query_winsec "$WQ4769" | python3 -c "import json,sys; h=json.load(sys.stdin)['hits']['hits']; print(json.dumps(h[0]['_source'],indent=2) if h else '')" > "${OUT}/winsec-4769-primary.json"

WQ4624=$(cat <<EOF
{"size":1,"sort":[{"@timestamp":"desc"}],"query":{"bool":{"must":[{"range":{"@timestamp":{"gte":"${T0}"}}},{"term":{"host.name":"dc01"}},{"term":{"winlog.event_id":"4624"}},{"term":{"source.ip":"192.168.77.60"}}]}}}
EOF
)
query_winsec "$WQ4624" | python3 -c "import json,sys; h=json.load(sys.stdin)['hits']['hits']; print(json.dumps(h[0]['_source'],indent=2) if h else '')" > "${OUT}/winsec-4624-sample.json"

curl -s "${ES}/logs-zeek.kerberos-*/_search" -H 'Content-Type: application/json' -d "{\"size\":1,\"sort\":[{\"@timestamp\":\"desc\"}],\"query\":{\"bool\":{\"must\":[{\"range\":{\"@timestamp\":{\"gte\":\"${T0}\"}}},{\"term\":{\"source.ip\":\"192.168.77.60\"}}]}}}" \
  | python3 -c "import json,sys; h=json.load(sys.stdin)['hits']['hits']; print(json.dumps(h[0]['_source'],indent=2) if h else '')" > "${OUT}/zeek-kerberos-sample.json"

echo "=== COUNTS post-T0 ==="
for q in winsec4769 winsec4624 zeek; do
  case $q in
    winsec4769) body="$WQ4769" idx="logs-system.security-*" ;;
    winsec4624) body="$WQ4624" idx="logs-system.security-*" ;;
    zeek) body="{\"size\":0,\"query\":{\"bool\":{\"must\":[{\"range\":{\"@timestamp\":{\"gte\":\"${T0}\"}}},{\"term\":{\"source.ip\":\"192.168.77.60\"}}]}}}" idx="logs-zeek.kerberos-*" ;;
  esac
  c=$(curl -s "${ES}/${idx}/_search" -H 'Content-Type: application/json' -d "$(echo "$body" | sed 's/"size":1/"size":0/')" | python3 -c "import json,sys; t=json.load(sys.stdin)['hits']['total']; print(t.get('value',t) if isinstance(t,dict) else t)")
  echo "$q=$c"
done

ls -la "$OUT"
echo "T0=$T0" > "${HOME}/cadre-evidence/${CASE_ID}/meta.txt"
