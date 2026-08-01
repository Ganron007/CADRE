#!/bin/bash
# PHASE 2: fresh install + wait + verify — CONFIG via WinRM (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
echo "=== FRESH INSTALL ==="
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-fresh-final.ps1)"
echo "=== Waiting 360s for registration/assignment ==="
sleep 360
echo "=== VERIFY ==="
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-verify-assign.ps1)"
