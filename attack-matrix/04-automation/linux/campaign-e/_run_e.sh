#!/bin/bash
# Plan 1.1 M5 — stage campaign-e script so ../lib resolves to linux/lib.
set -euo pipefail
_RUN_E_HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_RUN_E_AUTO="$(cd "${_RUN_E_HERE}/../.." && pwd)"
_run_e() {
  local name="$1"
  local src="${_RUN_E_AUTO}/campaign-e/${name}"
  if [[ ! -f "$src" ]]; then
    echo "[-] missing campaign-e script: $src" >&2
    return 1
  fi
  local stage
  stage="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf \"${stage}\"" RETURN
  ln -s "${_RUN_E_HERE}/../lib" "${stage}/lib"
  mkdir -p "${stage}/campaign-e"
  cp "$src" "${stage}/campaign-e/${name}"
  (cd "${stage}/campaign-e" && bash "./${name}")
}
