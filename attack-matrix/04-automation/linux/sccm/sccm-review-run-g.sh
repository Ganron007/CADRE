#!/bin/bash
# SCCM mbr02 post-reinstall AdminService verification runner (run ON provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-review-mbr02-g.ps1)
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$SCRIPT"
echo "=== SMS_ADMIN_SERVICE component (as svc_sccm) ==="
/home/vagrant/campaign-venv/bin/wmiquery.py -namespace '//./root/SMS/site_CAD' -file /tmp/sccm-wql-site-cad.txt 'range/svc_sccm:s3rv1c3_SCCM!@192.168.77.23' 2>&1 | grep -iE 'SMS_ADMIN_SERVICE|SMS Provider|RoleName|WBEM'
