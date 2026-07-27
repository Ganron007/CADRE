#!/bin/bash
# Plan 1.1 M5 thin wrapper — F-03: Workflow injection (.github/workflows/)
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HERE/_run_f.sh"
_run_f_scenario 3 'F-03 — Workflow injection (.github/workflows/)'
