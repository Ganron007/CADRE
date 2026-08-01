#!/bin/bash
# SCCM mbr02: switch SMS_EXECUTIVE to svc_sccm + add admin to SMS Admins (run ON provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-exec-as-svcsccm.ps1)
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$SCRIPT"
