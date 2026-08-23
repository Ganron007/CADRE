#!/usr/bin/env bash
# ATTACK lane: provisioning orchestrator → SSH to ws01 (Rule 1).
# Payload is always a file on ws01 (avoids Win32 CreateProcess 32k limit).
# Same-user: powershell -File as analyst_t1.
# Other-user: vagrant runs ws01-exec-hop.ps1 (SeBatchLogonRight + schtasks).
set -euo pipefail

WS01_IP="${WS01_IP:-192.168.77.62}"
WS01_SSH_USER="${WS01_SSH_USER:-analyst_t1}"
WS01_SSH_KEY="${WS01_SSH_KEY:-${HOME}/.ssh/cadre-ws01-key}"
WS01_AD_USER="${WS01_AD_USER:-analyst_t1}"
WS01_AD_PASS="${WS01_AD_PASS:-}"
WS01_DOMAIN="${WS01_DOMAIN:-child.cadre.local}"
WS01_ADMIN_SSH_USER="${WS01_ADMIN_SSH_USER:-vagrant}"
WS01_REMOTE_CMD="C:/Users/Public/cadre-ws01-exec-cmd.ps1"
WS01_REMOTE_HOP="C:/Users/Public/cadre-ws01-exec-hop.ps1"

CMD="${1:?usage: ws01-exec.sh '<powershell command>'}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOP_LOCAL="${HERE}/ws01-exec-hop.ps1"

if ! command -v ssh >/dev/null 2>&1; then
  echo "ssh not found on PATH" >&2
  exit 1
fi
if [[ ! -f "${WS01_SSH_KEY}" ]]; then
  echo "missing SSH key ${WS01_SSH_KEY}" >&2
  exit 1
fi
if [[ ! -f "${HOP_LOCAL}" ]]; then
  echo "missing ${HOP_LOCAL}" >&2
  exit 1
fi

_fail_closed_scan() {
  local out="$1"
  if printf '%s' "${out}" | grep -qiE '\[localhost\] Access is denied|Connecting to remote server localhost failed|WinRM cannot process the request|PSSessionStateBroken'; then
    echo "ws01-exec: remote WinRM/privilege failure (fail-closed)" >&2
    return 1
  fi
  return 0
}

_ssh_as() {
  local user="$1"
  shift
  ssh -i "${WS01_SSH_KEY}" \
    -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile="${HOME}/.ssh/cadre-known_hosts" \
    "${user}@${WS01_IP}" "$@"
}

_scp_as() {
  local user="$1"
  local src="$2"
  local dest="$3"
  scp -i "${WS01_SSH_KEY}" \
    -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile="${HOME}/.ssh/cadre-known_hosts" \
    "${src}" "${user}@${WS01_IP}:${dest}"
}

_run_remote() {
  local user="$1"
  local remote="$2"
  local out rc
  set +e
  out=$(_ssh_as "${user}" "${remote}" 2>&1)
  rc=$?
  set -e
  printf '%s\n' "${out}"
  _fail_closed_scan "${out}" || return 1
  return "${rc}"
}

STAGE="$(mktemp)"
printf '%s\n' "${CMD}" > "${STAGE}"
# vagrant can always write C:\Users\Public
_scp_as "${WS01_ADMIN_SSH_USER}" "${STAGE}" "${WS01_REMOTE_CMD}"
rm -f "${STAGE}"

if [[ "${WS01_AD_USER}" == "${WS01_SSH_USER}" ]]; then
  _run_remote "${WS01_SSH_USER}" "powershell -NoProfile -ExecutionPolicy Bypass -File ${WS01_REMOTE_CMD}"
  exit $?
fi

if [[ -z "${WS01_AD_PASS}" ]]; then
  echo "ws01-exec: password required for user ${WS01_AD_USER}" >&2
  exit 1
fi

ARGS="$(mktemp)"
python3 - "${ARGS}" "${WS01_DOMAIN}" "${WS01_AD_USER}" "${WS01_AD_PASS}" "${WS01_REMOTE_CMD}" <<'PY'
import json, sys
path, domain, user, password, script = sys.argv[1:6]
with open(path, "w", encoding="utf-8") as fh:
    json.dump({"Account": f"{domain}\\{user}", "Password": password, "ScriptPath": script}, fh)
PY
_scp_as "${WS01_ADMIN_SSH_USER}" "${HOP_LOCAL}" "${WS01_REMOTE_HOP}"
_scp_as "${WS01_ADMIN_SSH_USER}" "${ARGS}" "C:/Users/Public/cadre-ws01-exec-args.json"
rm -f "${ARGS}"
_run_remote "${WS01_ADMIN_SSH_USER}" \
  "powershell -NoProfile -ExecutionPolicy Bypass -File ${WS01_REMOTE_HOP}"
