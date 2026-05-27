#!/bin/bash
# CADRE common functions — sourced by all attack scripts
# Usage: source lib/common.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()     { echo -e "${CYAN}[*]${NC} $1"; }
step()    { echo -e "\n${YELLOW}[>]${NC} $1"; }
ok()      { echo -e "  ${GREEN}[+]${NC} $1"; }
fail()    { echo -e "  ${RED}[-]${NC} $1"; }
header()  { echo -e "\n${CYAN}========== $1 ==========${NC}\n"; }
result()  {
  if [ "$1" -eq 0 ]; then ok "$2";
  else fail "$2 (exit $1)"; fi
}

run_cmd() {
  echo -e "  ${YELLOW}\$${NC} $1"
  eval "$1"
  return $?
}

require_tool() {
  if ! command -v "$1" &>/dev/null; then
    fail "Required tool not found: $1"
    exit 1
  fi
}

require_env() {
  if [ -z "$1" ]; then
    fail "Required env var not set: $2"
    exit 1
  fi
}

start_attack() {
  header "WT#$1 — $2"
  log "Starting at $(date '+%H:%M:%S')"
}

print_banner() {
  echo ""
  echo "  CADRE Attack Automation — $1"
  echo "  $(date)"
  echo "================================================"
}
