#!/bin/bash
# CADRE — WT#034 SCCM NAA Extraction
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#034 — SCCM NAA Extraction"
start_attack "034" "SCCM NAA Extraction"

require_env SCCM_SERVER "SCCM_SERVER"

step "Run SharpSCCM from Windows attack host"
echo "WT#034 requires SharpSCCM on Windows — see walkthrough doc"

result 0 "SCCM NAA Extraction (Windows-only — see walkthrough)"
