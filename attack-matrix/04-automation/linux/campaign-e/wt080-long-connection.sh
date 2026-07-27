#!/bin/bash
# Plan 1.1 M5 thin wrapper — Campaign E / wt080-long-connection.sh
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HERE/_run_e.sh"
_run_e 'wt080-long-connection.sh'
