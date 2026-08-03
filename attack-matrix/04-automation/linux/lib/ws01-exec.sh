#!/usr/bin/env bash
# ATTACK lane: provisioning orchestrator → direct SSH to ws01 (Rule 1).
# Beachhead SSH user is analyst_t1 (key-based). Other users run via Invoke-Command on ws01.
set -euo pipefail

WS01_IP="${WS01_IP:-192.168.77.62}"
WS01_SSH_USER="${WS01_SSH_USER:-analyst_t1}"
WS01_SSH_KEY="${WS01_SSH_KEY:-${HOME}/.ssh/cadre-ws01-key}"
WS01_AD_USER="${WS01_AD_USER:-analyst_t1}"
WS01_AD_PASS="${WS01_AD_PASS:-}"
WS01_DOMAIN="${WS01_DOMAIN:-child.cadre.local}"

CMD="${1:?usage: ws01-exec.sh '<powershell command>'}"

if ! command -v ssh >/dev/null 2>&1; then
  echo "ssh not found on PATH" >&2
  exit 1
fi

if [[ ! -f "${WS01_SSH_KEY}" ]]; then
  echo "missing SSH key ${WS01_SSH_KEY}" >&2
  exit 1
fi

_ssh() {
  ssh -i "${WS01_SSH_KEY}" \
    -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile="${HOME}/.ssh/cadre-known_hosts" \
    "${WS01_SSH_USER}@${WS01_IP}" "$@"
}

if [[ "${WS01_AD_USER}" == "${WS01_SSH_USER}" ]]; then
  REMOTE="powershell -NoProfile -ExecutionPolicy Bypass -Command \"${CMD}; exit \$LASTEXITCODE\""
  _ssh "${REMOTE}"
else
  if [[ -z "${WS01_AD_PASS}" ]]; then
    echo "ws01-exec: password required for user ${WS01_AD_USER}" >&2
    exit 1
  fi
  B64=$(printf '%s' "${CMD}" | iconv -t UTF-16LE | base64 -w0)
  REMOTE="\$__p=ConvertTo-SecureString '${WS01_AD_PASS}' -AsPlainText -Force; \$__c=New-Object System.Management.Automation.PSCredential('${WS01_DOMAIN}\\${WS01_AD_USER}',\$__p); \$__bytes=[Convert]::FromBase64String('${B64}'); \$__cmd=[Text.Encoding]::Unicode.GetString(\$__bytes); \$__sb=[scriptblock]::Create(\$__cmd); Invoke-Command -ComputerName localhost -Credential \$__c -ScriptBlock \$__sb; exit \$LASTEXITCODE"
  _ssh "powershell -NoProfile -ExecutionPolicy Bypass -Command \"${REMOTE}\""
fi
