#!/bin/bash
# Install v2 (no /mp, local source) + wait + verify — CONFIG via WinRM (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
echo "=== INSTALL v2 (no /mp) ==="
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-fresh-install2.ps1)"
echo "=== Waiting 240s for client to register/assign ==="
sleep 240
echo "=== VERIFY ==="
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-verify-assign.ps1)"
