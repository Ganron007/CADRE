#!/bin/bash
# Fresh client install (correct syntax) + wait + verify — CONFIG via WinRM (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
echo "=== INSTALL ==="
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-fresh-install.ps1)"
echo "=== Waiting 300s for client to register/assign ==="
sleep 300
echo "=== VERIFY ==="
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-verify-assign.ps1)"
