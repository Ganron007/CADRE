#!/bin/bash
# SCCM mbr02 review runner — as range\svc_naa, two chunks (nxc 8191-char limit)
NXC=/home/vagrant/campaign-venv/bin/nxc
A=$(cat /tmp/sccm-review-mbr02-a.ps1)
B=$(cat /tmp/sccm-review-mbr02-b.ps1)

echo "=== REVIEW A ==="
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$A"
echo "=== REVIEW B ==="
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$B"
