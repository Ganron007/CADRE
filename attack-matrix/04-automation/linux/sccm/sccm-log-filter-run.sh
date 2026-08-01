#!/bin/bash
# Filtered ccmsetup.log for the 17:44 run — CONFIG via WinRM (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-log-filter.ps1)"
