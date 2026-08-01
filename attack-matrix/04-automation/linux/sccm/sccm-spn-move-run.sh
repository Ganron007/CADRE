#!/bin/bash
# Move HTTP/mbr02.range.local SPN to mbr02$ on dc03 (run ON provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-spn-move.ps1)
$NXC smb 192.168.77.12 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$SCRIPT"
