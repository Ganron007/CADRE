#!/bin/bash
# Assign via registry + restart CcmExec, wait, verify — CONFIG via WinRM (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
echo "=== ASSIGN (registry) ==="
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-assign-reg.ps1)"
echo "=== Waiting 240s for policy/registration ==="
sleep 240
echo "=== VERIFY ==="
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-verify-assign.ps1)"
