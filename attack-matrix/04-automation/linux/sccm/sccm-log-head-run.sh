#!/bin/bash
# Head of ccmsetup.log + reboot state on mbr02 — CONFIG via WinRM (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-log-head.ps1)"
