#!/bin/bash
# CADRE — WT#030 WSUS Abuse
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#030 — WSUS Abuse"
start_attack "030" "WSUS Abuse"

require_env MBR01 "MBR01"

step "Run SharpWSUS from Windows attack host"
echo "WT#030 requires SharpWSUS on Windows — see walkthrough doc"

result 0 "WSUS Abuse (Windows-only — see walkthrough)"
