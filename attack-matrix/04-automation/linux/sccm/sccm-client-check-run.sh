#!/bin/bash
# Check ConfigMgr client on mbr02 (run ON provisioning) — uses svc_naa (local admin)
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-client-check.ps1)
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$SCRIPT"
