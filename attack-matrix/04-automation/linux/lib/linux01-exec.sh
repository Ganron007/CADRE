#!/usr/bin/env bash
# ATTACK lane: provisioning → SSH to linux01 (Branch D).
# Default: vagrant@192.168.77.40 with key or sshpass fallback.
set -euo pipefail

LINUX01_IP="${LINUX01_IP:-192.168.77.40}"
LINUX01_USER="${LINUX01_USER:-vagrant}"
LINUX01_SSH_KEY="${LINUX01_SSH_KEY:-${HOME}/.ssh/cadre-linux01-key}"
LINUX01_PASS="${LINUX01_PASS:-vagrant}"

CMD="${1:?usage: linux01-exec.sh '<remote bash command>'}"

# Encode remote script so multiline payloads survive SSH argv
B64=$(printf '%s' "${CMD}" | base64 -w0 2>/dev/null || printf '%s' "${CMD}" | base64 | tr -d '\n')
REMOTE="echo ${B64} | base64 -d | bash"

_ssh_key() {
  ssh -i "${LINUX01_SSH_KEY}" \
    -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile="${HOME}/.ssh/cadre-known_hosts" \
    -o ConnectTimeout=10 \
    "${LINUX01_USER}@${LINUX01_IP}" "$@"
}

_ssh_pass() {
  if command -v sshpass >/dev/null 2>&1; then
    sshpass -p "${LINUX01_PASS}" ssh \
      -o StrictHostKeyChecking=accept-new \
      -o UserKnownHostsFile="${HOME}/.ssh/cadre-known_hosts" \
      -o ConnectTimeout=10 \
      "${LINUX01_USER}@${LINUX01_IP}" "$@"
  else
    echo "linux01-exec: no key at ${LINUX01_SSH_KEY} and sshpass missing" >&2
    exit 1
  fi
}

if [[ -f "${LINUX01_SSH_KEY}" ]]; then
  _ssh_key "${REMOTE}"
else
  _ssh_pass "${REMOTE}"
fi
