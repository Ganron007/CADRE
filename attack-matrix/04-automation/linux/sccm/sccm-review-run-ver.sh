#!/bin/bash
# SCCM mbr02 version check runner
NXC=/home/vagrant/campaign-venv/bin/nxc
V=$(cat /tmp/sccm-review-mbr02-ver.ps1)
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$V"
