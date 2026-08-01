#!/usr/bin/env bash
set -u
bloodyAD --host dc01.cadre.local -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' remove shadowCredentials 'dc01$' --key 38c620764eb142c7ccafb78d0757ed78e8278932f3859023569dd481feb5b0e5 2>&1 | tail -5
echo "EXIT=$?"
# Verify the KeyCredentialLink attribute is now empty/absent
export KRB5_CONFIG=/tmp/krb5-cadre.conf
export KRB5CCNAME=/tmp/t008/dc01_keycred.ccache
cd /tmp/nxc-venv/bin
timeout 30 ./nxc ldap dc01.cadre.local -u 'chief_command' -p 'C0mm@nd_Ch1ef!' --query '(&(sAMAccountName=dc01$))' 'msDS-KeyCredentialLink' 2>&1 | tail -6
