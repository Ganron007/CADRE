#!/bin/bash
# Plan 1.1 M5 thin wrapper — F-05: Multi-stage /tmp download+exec
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HERE/_run_f.sh"
_run_f_scenario 5 'F-05 — Multi-stage /tmp download+exec'
