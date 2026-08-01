#!/bin/bash
# AD publication check v2 — CONFIG via WinRM (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-ad-publish2.ps1)"
