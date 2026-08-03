#!/usr/bin/env bash
# Shared helpers for Campaign H (Rule 4: provisioning attacker, ws01 target).
set -euo pipefail

CAMPAIGN_H_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="${HOME}/.local/bin:${PATH}"

H_WWW="${H_WWW:-${HOME}/www}"
H_HTTP="${H_HTTP:-http://127.0.0.1:8081}"
H_WS01_HTTP="${H_WS01_HTTP:-http://192.168.77.60:8081}"

h_require_artifact() {
  local name="$1"
  local path="${H_WWW}/${name}"
  if [[ ! -f "${path}" ]]; then
    echo "H_FAIL: missing artifact ${path}" >&2
    exit 1
  fi
  local sz
  sz=$(wc -c < "${path}" | tr -d ' ')
  echo "H_ARTIFACT_OK name=${name} size=${sz}"
  local code
  code=$(curl -s -o /dev/null -w '%{http_code}' "${H_HTTP}/${name}" || true)
  if [[ "${code}" != "200" ]]; then
    echo "H_WARN: HTTP ${code} for ${H_HTTP}/${name} — starting python http.server if needed"
    if ! ss -lnt 2>/dev/null | grep -q ':8081'; then
      nohup python3 -m http.server 8081 --directory "${H_WWW}" >"${HOME}/www-server.log" 2>&1 &
      sleep 1
      code=$(curl -s -o /dev/null -w '%{http_code}' "${H_HTTP}/${name}" || true)
    fi
  fi
  [[ "${code}" == "200" ]] || { echo "H_FAIL: HTTP ${code} for ${name}" >&2; exit 1; }
  echo "H_HTTP_OK ${name} code=${code}"
}

h_ws01_exec() {
  local cmd="$1"
  WS01_AD_USER="${WS01_AD_USER:-analyst_t1}" \
  WS01_AD_PASS="${WS01_AD_PASS:-T13r_An@lyst!}" \
  WS01_DOMAIN="${WS01_DOMAIN:-child.cadre.local}" \
    bash "${CAMPAIGN_H_LIB}/../lib/ws01-exec.sh" "${cmd}"
}
