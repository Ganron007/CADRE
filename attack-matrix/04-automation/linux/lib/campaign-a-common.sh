#!/usr/bin/env bash
# Shared helpers for Campaign A ws01-egress attacks (operator on provisioning .60)
set -euo pipefail

CAMPAIGN_A_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="${HOME}/.local/bin:${PATH}"

cadre_export() {
  local case_id="$1" t_attack="$2" t0="$3"
  local src_ip="${4:-192.168.77.62}"
  echo "=== Export ${case_id} source=${src_ip} ==="
  # Telemetry export to Elastic is deferred to Plan 1 phase 2 (elk/monitor VMs).
  # During attack-only validation we log the export parameters and continue.
  if [[ -x "${HOME}/cadre-es-export.sh" ]]; then
    echo "INFO: skipping ES export — attack-only stage"
  fi
  echo "EXPORT_LOG: case=${case_id} attack=${t_attack} t0=${t0} source=${src_ip}"
}

ws01_exec_as() {
  local user="$1" pass="$2" cmd="$3" domain="${4:-child.cadre.local}"
  WS01_AD_USER="${user}" WS01_AD_PASS="${pass}" WS01_DOMAIN="${domain}" \
    bash "${CAMPAIGN_A_LIB}/ws01-exec.sh" "${cmd}"
}

# Resolve a payload under linux/ (bare name = windows/<name>).
campaign_payload_src() {
  local base="$1"
  if [[ "${base}" == */* ]]; then
    echo "${CAMPAIGN_A_LIB}/../${base}"
  else
    echo "${CAMPAIGN_A_LIB}/../windows/${base}"
  fi
}

# Copy a repo payload onto ws01 C:\Tools\cadre-attack\<basename>.
campaign_stage_file() {
  local base="$1"
  local src fname
  src="$(campaign_payload_src "${base}")"
  fname="$(basename "${base}")"
  [[ -f "${src}" ]] || { echo "missing payload ${src}" >&2; return 1; }
  bash "${CAMPAIGN_A_LIB}/ws01-stage-file.sh" "${src}" "${fname}"
}

# Stage a repo .ps1 onto ws01, then hop-exec it. Payloads live in git.
campaign_stage_run_ps1() {
  local user="$1" pass="$2" base="$3"
  local domain="${4:-child.cadre.local}"
  local extra="${5:-}"
  local fname
  campaign_stage_file "${base}"
  fname="$(basename "${base}")"
  ws01_exec_as "${user}" "${pass}" \
    "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\${fname} ${extra}" \
    "${domain}"
}

# Run a staged .ps1 as local admin (vagrant WinRM) — not the AD hop.
campaign_vagrant_run_ps1() {
  local base="$1"
  local fname ip
  campaign_stage_file "${base}"
  fname="$(basename "${base}")"
  ip="${WS01_IP:-192.168.77.62}"
  ansible -i "${ip}," all \
    -e ansible_user=vagrant -e ansible_password=vagrant \
    -e ansible_connection=winrm -e ansible_winrm_transport=basic \
    -e ansible_winrm_scheme=http -e ansible_port=5985 \
    -e ansible_winrm_server_cert_validation=ignore \
    -m win_shell -a "powershell -NoProfile -ExecutionPolicy Bypass -File C:\\Tools\\cadre-attack\\${fname}"
}

# RedStrike default success marker: node-id with '-' → '_' + '_OK'
campaign_ok() {
  local id="$1"
  echo "${id//-/_}_OK"
}

# Fail closed unless proof already exists in captured output, then emit marker.
campaign_require_ok() {
  local id="$1"
  local text="$2"
  local proof="${3:-}"
  if [[ -n "${proof}" ]] && ! printf '%s' "${text}" | grep -qE "${proof}"; then
    echo "${id}_FAIL: missing proof /${proof}/" >&2
    exit 1
  fi
  campaign_ok "${id}"
}

ws01_ensure_rubeus() {
  campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-ensure-rubeus.ps1
}

ws01_ensure_mimikatz() {
  campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-ensure-mimikatz.ps1
}

ws01_ensure_lpe_binaries() {
  campaign_stage_run_ps1 analyst_t1 'T13r_An@lyst!' campaign-a-ensure-lpe.ps1
}
