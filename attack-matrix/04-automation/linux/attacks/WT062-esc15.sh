#!/bin/bash
# BROKEN—Server 2025 PKI rejects v1 templates (Server 2025 CA rejects v1 templates)
source "$(dirname "$0")/../lib/cadre-env.sh"
source "$(dirname "$0")/../lib/common.sh"

start_attack "062" "ESC15 — v1 template abuse (excluded on Server 2025)"

log "WT#062 — ESC15 excluded (Server 2025 CA rejects v1 templates)"
echo "Server 2025 PKI refuses to issue from v1 (legacy) certificate templates."
echo "ESC15 is non-exploitable in this environment — CADRE will not test it."
exit 1
