#!/usr/bin/env bash
# CADRE lab log reset — run ON provisioning (.60) as vagrant (config lane).
# Wipes old DFIR Windows channels, linux01 playbook logs, monitor NSM, ES logs-* history.
# Live refill after the wipe is expected. Does not delete Fleet / ILM / data streams.
set -euo pipefail

ANSIBLE_ROOT="${CADRE_ANSIBLE_ROOT:-$HOME/ansible}"
PLAY="${ANSIBLE_ROOT}/playbooks/20-lab-log-reset.yml"
INV="${ANSIBLE_ROOT}/inventories/hosts"

if [[ ! -f "$PLAY" ]]; then
  echo "missing $PLAY — copy ansible/playbooks/20-lab-log-reset.yml onto provisioning" >&2
  exit 1
fi

cd "$ANSIBLE_ROOT"
# dc02 host_vars historically set ansible_password=V@gr@nt; live local admin is vagrant.
# Extra-vars wins so the wipe reaches every Windows host. Override with CADRE_WINRM_PASSWORD if needed.
WINRM_PASS="${CADRE_WINRM_PASSWORD:-vagrant}"
echo "=== lab-log-reset $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
ansible-playbook -i "$INV" playbooks/20-lab-log-reset.yml -e "ansible_password=${WINRM_PASS}"
echo "=== verify ==="
ansible-playbook -i "$INV" playbooks/20-lab-log-reset-verifyOnly.yml -e "ansible_password=${WINRM_PASS}"
echo "=== lab-log-reset done ==="
