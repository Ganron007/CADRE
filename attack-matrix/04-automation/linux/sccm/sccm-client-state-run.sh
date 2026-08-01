#!/bin/bash
# SCCM client state check on mbr02 — CONFIG via nxc as vagrant (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-client-state.ps1)
$NXC smb 192.168.77.23 -u vagrant -p 'vagrant' -d range -X "$SCRIPT"
