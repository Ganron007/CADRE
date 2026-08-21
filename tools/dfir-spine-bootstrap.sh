#!/usr/bin/env bash
# Runs on provisioning after the Windows host wrapper copies tarballs to /tmp.
# Usage: bash dfir-spine-bootstrap.sh [--execute]
set -euo pipefail

EXECUTE_ARG="${1:-}"
CADRE_ROOT="${HOME}/CADRE"
PIN="${CADRE_ROOT}/tools/red-strike"
AUTO="${CADRE_ROOT}/attack-matrix/04-automation/linux"
GLUE="${CADRE_ROOT}/attack-matrix/Campaign/automation"

mkdir -p "${PIN}" "${AUTO}" "${GLUE}" "${CADRE_ROOT}/tools"

if [[ -f /tmp/redstrike-pin.tgz ]]; then
  tar -xzf /tmp/redstrike-pin.tgz -C "${PIN}"
fi
if [[ -f /tmp/linux-auto.tgz ]]; then
  tar -xzf /tmp/linux-auto.tgz -C "${AUTO}"
fi
[[ -f /tmp/dfir-full-ready-check.py ]] && mv -f /tmp/dfir-full-ready-check.py "${CADRE_ROOT}/tools/"
[[ -f /tmp/dfir-spine-ready-check.py ]] && mv -f /tmp/dfir-spine-ready-check.py "${CADRE_ROOT}/tools/"
[[ -f /tmp/redstrike-dfir-full.sh ]] && mv -f /tmp/redstrike-dfir-full.sh "${AUTO}/"
[[ -f /tmp/redstrike-dfir-spine.sh ]] && mv -f /tmp/redstrike-dfir-spine.sh "${AUTO}/"
[[ -f /tmp/campaign-graph.yaml ]] && mv -f /tmp/campaign-graph.yaml "${GLUE}/"
[[ -f /tmp/lab-profiles.yaml ]] && mv -f /tmp/lab-profiles.yaml "${GLUE}/"
[[ -f /tmp/lab-seed-creds.json ]] && mv -f /tmp/lab-seed-creds.json "${GLUE}/"

# Host copies may be CRLF.
sed -i 's/\r$//' \
  "${AUTO}/redstrike-dfir-full.sh" \
  "${AUTO}/redstrike-dfir-spine.sh" \
  "${CADRE_ROOT}/tools/dfir-full-ready-check.py" \
  "${CADRE_ROOT}/tools/dfir-spine-ready-check.py" 2>/dev/null || true
chmod +x \
  "${AUTO}/redstrike-dfir-full.sh" \
  "${AUTO}/redstrike-dfir-spine.sh" \
  "${CADRE_ROOT}/tools/dfir-full-ready-check.py" \
  "${CADRE_ROOT}/tools/dfir-spine-ready-check.py" || true
if [[ -f "${AUTO}/lib/ws01-exec.sh" ]]; then
  chmod +x "${AUTO}/lib/ws01-exec.sh"
fi
if [[ -f "${AUTO}/lib/linux01-exec.sh" ]]; then
  chmod +x "${AUTO}/lib/linux01-exec.sh"
fi
find "${AUTO}" -name '*.sh' -type f -exec chmod +x {} +

if [[ ! -x "${PIN}/.venv/bin/redstrike-campaign" ]]; then
  echo "=== creating pin venv on provisioning ==="
  python3 -m venv "${PIN}/.venv"
  "${PIN}/.venv/bin/python" -m pip install -U pip wheel
  if ! "${PIN}/.venv/bin/pip" install -e "${PIN}"; then
    echo "WARN: pip install from PyPI failed — trying standalone venv copy"
    if [[ -d "${HOME}/RedStrike/.venv" ]]; then
      rm -rf "${PIN}/.venv"
      cp -a "${HOME}/RedStrike/.venv" "${PIN}/.venv"
      "${PIN}/.venv/bin/pip" install -e "${PIN}"
    else
      echo "FAIL: cannot install pin venv and ~/RedStrike/.venv is missing"
      exit 1
    fi
  fi
fi

export CADRE_ROOT
export REDSTRIKE_WS01_SSH_KEY="${HOME}/.ssh/cadre-ws01-key"
bash "${AUTO}/redstrike-dfir-full.sh" ${EXECUTE_ARG}
