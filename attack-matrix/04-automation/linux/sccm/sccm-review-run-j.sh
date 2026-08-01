#!/bin/bash
# SCCM mbr02 part J runner (run ON provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-review-mbr02-j.ps1)
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$SCRIPT"
echo "=== wmiquery retry as svc_sccm ==="
/home/vagrant/campaign-venv/bin/wmiquery.py -namespace '//./root/SMS/site_CAD' -file /tmp/sccm-wql-components.txt 'range/svc_sccm:s3rv1c3_SCCM!@192.168.77.23' 2>&1
