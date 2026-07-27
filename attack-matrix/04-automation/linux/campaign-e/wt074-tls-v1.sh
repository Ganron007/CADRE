#!/bin/bash
# Plan 1.1 M5 thin wrapper — Campaign E / wt074-tls-v1.sh
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$HERE/_run_e.sh"
_run_e 'wt074-tls-v1.sh'
