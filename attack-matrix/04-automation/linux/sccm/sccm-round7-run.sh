#!/bin/bash
# Round 7 — CONFIG via WinRM as local vagrant (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-round7.ps1)
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$SCRIPT"
