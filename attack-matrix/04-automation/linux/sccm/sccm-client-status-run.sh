#!/bin/bash
# Site-side client status — CONFIG via WinRM (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-client-status.ps1)"
