#!/bin/bash
# CADRE — WT#035 SCCM PXE Boot Abuse
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#035 — SCCM PXE Boot Abuse"
start_attack "035" "SCCM PXE Boot Abuse"

require_env SCCM_SERVER "SCCM_SERVER"

step "Run PXEThief from Windows attack host"
echo "WT#035 requires PXEThief on Windows — see walkthrough doc"

result 0 "SCCM PXE Boot Abuse (Windows-only — see walkthrough)"
