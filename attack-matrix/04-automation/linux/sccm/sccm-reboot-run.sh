#!/bin/bash
# Reboot mbr02 via WinRM (CONFIG, from provisioning), then wait for it to come back
NXC=/home/vagrant/campaign-venv/bin/nxc
$NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "$(cat /tmp/sccm-reboot.ps1)" >/dev/null 2>&1
echo "Reboot command sent. Waiting for mbr02 to come back..."
for i in $(seq 1 60); do
  if ping -c 1 -W 1 192.168.77.23 >/dev/null 2>&1; then
    # machine answers ping; wait for WinRM to be responsive again
    for j in $(seq 1 30); do
      sleep 5
      if $NXC winrm 192.168.77.23 -u vagrant -p 'vagrant' --local-auth -X "Get-Date" >/dev/null 2>&1; then
        echo "MBR02 BACK UP after ~$((i*2 + j*5))s"
        exit 0
      fi
    done
    echo "MBR02 pings but WinRM not back after 150s"
    exit 1
  fi
  sleep 2
done
echo "MBR02 did not come back after 120s"
exit 1
