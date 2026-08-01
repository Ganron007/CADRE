#!/bin/bash
# PHASE 1B: disable + kill + clean + reboot — CONFIG via WinRM (from provisioning)
NXC=/home/vagrant/campaign-venv/bin/nxc
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-true-uninstall2.ps1)"
echo "Waiting for reboot..."
for i in $(seq 1 60); do
  if ping -c 1 -W 1 192.168.77.23 >/dev/null 2>&1; then
    for j in $(seq 1 40); do
      sleep 5
      if $NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "Get-Date" >/dev/null 2>&1; then
        echo "MBR02 BACK UP"
        exit 0
      fi
    done
  fi
  sleep 2
done
echo "MBR02 did not come back"
exit 1
