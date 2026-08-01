#!/bin/bash
# SCCM mbr02 config review runner (run ON provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc

echo "=== TEST EXEC (svc_sccm) ==="
$NXC smb 192.168.77.23 -u svc_sccm -p 's3rv1c3_SCCM!' -d range -X 'whoami; hostname'

echo "=== REVIEW (svc_sccm) ==="
SCRIPT=$(cat /tmp/sccm-review-mbr02.ps1)
$NXC smb 192.168.77.23 -u svc_sccm -p 's3rv1c3_SCCM!' -d range -X "$SCRIPT"
