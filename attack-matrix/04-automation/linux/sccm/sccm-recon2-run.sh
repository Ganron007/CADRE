#!/bin/bash
# Deep client check on mbr02 (run ON provisioning) — svc_naa
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-client-deep.ps1)
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$SCRIPT"
echo '=== ResourceID via wmiquery (svc_sccm) ==='
cat > /tmp/q_devices.wql <<'EOF'
SELECT ResourceID,Name,Client,ClientVersion FROM SMS_R_System
EOF
/home/vagrant/campaign-venv/bin/wmiquery.py -namespace '//./root/SMS/site_CAD' -file /tmp/q_devices.wql 'range/svc_sccm:s3rv1c3_SCCM!@192.168.77.23' 2>&1 | tail -20
echo '=== AdminService SMS_R_System (no filter, first 1500) ==='
CC=/tmp/administrator@HTTP_mbr02.range.local@RANGE.LOCAL.ccache
KRB5CCNAME=$CC curl -k -s --negotiate -u : --max-time 30 'https://mbr02.range.local/AdminService/wmi/SMS_R_System' 2>&1 | head -c 1500
echo
