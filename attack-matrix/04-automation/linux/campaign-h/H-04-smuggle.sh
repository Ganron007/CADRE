#!/usr/bin/env bash
# H-04 HTML smuggling — builder/artifact verify (browser detonation = user practice)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/h-common.sh"
echo "=== H-04 HTML Smuggling ==="
h_require_artifact "H-04-smuggle.html"
# Confirm payload blob embedded (size > empty page)
sz=$(wc -c < "${H_WWW}/H-04-smuggle.html" | tr -d ' ')
[[ "${sz}" -gt 1000 ]] || { echo "H04_FAIL: html too small (${sz})" >&2; exit 1; }
echo "H04_BUILDER_OK size=${sz}"
echo "H_04_OK"
echo "H04_DONE"
