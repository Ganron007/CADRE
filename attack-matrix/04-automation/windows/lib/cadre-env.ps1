# CADRE environment variables — dot-sourced by all attack scripts
# Usage: . .\lib\cadre-env.ps1

# Network
$DC01 = "192.168.77.10"
$DC02 = "192.168.77.11"
$DC03 = "192.168.77.12"
$MBR01 = "192.168.77.22"
$MBR02 = "192.168.77.23"
$LINUX01 = "192.168.77.40"
# $KALI = "192.168.77.41"  # Kali — Plan 1

# Domains
$DOMAIN_ROOT = "cadre.local"
$DOMAIN_CHILD = "child.cadre.local"
$DOMAIN_EXT = "range.local"
$NETBIOS_ROOT = "CADRE"
$NETBIOS_CHILD = "CHILD"
$NETBIOS_EXT = "RANGE"

# Standard attack user
$ATTACK_USER = "analyst_dfir"
$ATTACK_PASS = ConvertTo-SecureString 'An@lyst_DF1R!' -AsPlainText -Force
$ATTACK_CRED = New-Object System.Management.Automation.PSCredential("$DOMAIN_ROOT\$ATTACK_USER", $ATTACK_PASS)

# MSSQL
$MSSQL_SA_PASS = 's@_P@ssw0rd!L@b!'

# SCCM
$SCCM_SITE = "CAD"
$SCCM_SERVER = $MBR02

# ADCS
$CA_NAME = "cadre-CA"
$CA_HOST = $DC01
