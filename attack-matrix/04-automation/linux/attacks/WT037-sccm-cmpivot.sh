#!/bin/bash
# CADRE — WT#037 SCCM CMPivot Abuse
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#037 — SCCM CMPivot Abuse"
start_attack "037" "SCCM CMPivot Abuse"

require_env SCCM_SERVER "SCCM_SERVER"

step "Run CMPivot from SCCM Console on Windows"
echo "WT#037 requires SCCM Console on Windows — see walkthrough doc"

result 0 "SCCM CMPivot Abuse (Windows-only — see walkthrough)"
