#!/bin/bash
# Compat wrapper — payload lives in campaign-a + linux/windows/campaign-a-t017.ps1
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/../campaign-a/T017-printerbug-ws01.sh" "$@"
