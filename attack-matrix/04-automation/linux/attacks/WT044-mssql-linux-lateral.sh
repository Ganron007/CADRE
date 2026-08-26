#!/bin/bash
# CADRE — WT#044 MSSQL-on-Linux linked-server recon (SQL query only)
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#044 — MSSQL-on-Linux Linked Recon"
start_attack "044" "MSSQL-on-Linux Linked Recon"

require_tool impacket-mssqlclient
require_env MBR01 "MBR01"
require_env DOMAIN_CHILD "DOMAIN_CHILD"

step "List databases on LINUX01 via 4-part name from mbr01 (SQL recon only)"
run_cmd "impacket-mssqlclient \"$DOMAIN_CHILD/analyst_t1:'T13r_An@lyst!'@$MBR01\" -windows-auth -query \"SELECT name FROM LINUX01.master.sys.databases\""

result $? "MSSQL-on-Linux linked recon completed"
