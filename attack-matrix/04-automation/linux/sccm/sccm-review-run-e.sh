#!/bin/bash
# SCCM mbr02 PART E runner (run ON provisioning) — provider registration + AdminService component/logs
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-review-mbr02-e.ps1)
$NXC smb 192.168.77.23 -u svc_naa -p 'N@A_s3rv1c3!' -d range -X "$SCRIPT"
