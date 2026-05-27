#!/bin/bash
# CADRE environment variables — sourced by all attack scripts
# Usage: source lib/cadre-env.sh

# Network
export DC01="192.168.77.10"
export DC02="192.168.77.11"
export DC03="192.168.77.12"
export MBR01="192.168.77.22"
export MBR02="192.168.77.23"
export LINUX01="192.168.77.40"
# export KALI="192.168.77.41"  # Kali — Plan 1
export ELK="192.168.77.50"
export VR="192.168.77.51"
export MONITOR="192.168.77.55"

# Domains
export DOMAIN_ROOT="cadre.local"
export DOMAIN_CHILD="child.cadre.local"
export DOMAIN_EXT="range.local"
export NETBIOS_ROOT="CADRE"
export NETBIOS_CHILD="CHILD"
export NETBIOS_EXT="RANGE"

# Standard attack user (low-priv, can enumerate)
export ATTACK_USER="analyst_dfir"
export ATTACK_PASS='An@lyst_DF1R!'
export ATTACK_DOMAIN="$DOMAIN_ROOT"

# Kerberoast targets
export KERBEROAST_TARGET="chief_command"
export KERBEROAST_SPN="HTTP/cadre-portal.cadre.local"

# AS-REP targets
export ASREP_USER_1="intern_blue"       # child.cadre.local
export ASREP_USER_2="intern_intel"      # range.local
export ASREP_USER_3="analyst_purple"    # cadre.local

# MSSQL
export MSSQL_SA_PASS='s@_P@ssw0rd!L@b!'
export MSSQL_USER="CHILD\\analyst_t1"
export MSSQL_PASS='T13r_An@lyst!'

# SCCM
export SCCM_SITE="CAD"
export SCCM_SERVER="$MBR02"
export SCCM_NAA_USER="RANGE\\svc_naa"
export SCCM_NAA_PASS='N@A_s3rv1c3!'

# ADCS
export CA_NAME="cadre-CA"
export CA_HOST="$DC01"
