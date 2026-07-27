#!/bin/bash
# Plan 1.1 M5 thin wrapper — Campaign E / wt075-smb-admin.sh
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HERE/_run_e.sh"
_run_e 'wt075-smb-admin.sh'
