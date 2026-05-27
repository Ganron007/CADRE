#!/bin/bash
# CADRE — WT#038 SCCM App Deployment
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#038 — SCCM App Deployment"
start_attack "038" "SCCM App Deployment"

require_env SCCM_SERVER "SCCM_SERVER"

step "Deploy malicious app from SCCM Console on Windows"
echo "WT#038 requires SCCM Console on Windows — see walkthrough doc"

result 0 "SCCM App Deployment (Windows-only — see walkthrough)"
