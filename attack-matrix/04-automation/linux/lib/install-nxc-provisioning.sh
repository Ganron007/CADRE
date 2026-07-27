#!/usr/bin/env bash
# Install NetExec on provisioning (.60) — winrm pivot to ws01 ONLY.
# Do NOT use nxc ldap/smb/mssql from .60 to DC/mbr — see WS01-ROUTING.md.
set -euo pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
  libssl-dev libffi-dev python3-dev pkg-config rustc cargo

pip3 install --user --break-system-packages \
  git+https://github.com/Pennyw0rth/NetExec.git

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/patch-oscrypto-nxc.sh"

echo "NetExec installed. Add to shell profile:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
export PATH="${HOME}/.local/bin:${PATH}"
nxc --version
