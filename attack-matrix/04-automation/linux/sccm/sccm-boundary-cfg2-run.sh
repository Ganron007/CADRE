#!/bin/bash
# Boundary/group fix round 3 — CONFIG via WinRM as local vagrant (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
SCRIPT=$(cat /tmp/sccm-boundary-cfg2.ps1)
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$SCRIPT"
