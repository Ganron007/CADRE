#!/bin/bash
# Plan 1.1 M5 thin wrapper — F-07: Cloud metadata probe (169.254.169.254)
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HERE/_run_f.sh"
_run_f_scenario 7 'F-07 — Cloud metadata probe (169.254.169.254)'
