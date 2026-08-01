#!/bin/bash
# Reboot all core Windows VMs via WinRM
NXC=/tmp/nxc-venv/bin/nxc

reboot_win() {
  local ip=$1; local u=$2; local p=$3; local name=$4
  echo "=== REBOOT $name ($ip) ==="
  $NXC winrm "$ip" -u "$u" -p "$p" -X 'shutdown /r /t 5 /f' 2>&1 | grep -E '\[+\]|\[-\]|Executed|error' | head -4
}

reboot_win 192.168.77.10 vagrant vagrant DC01
reboot_win 192.168.77.11 vagrant vagrant DC02
reboot_win 192.168.77.12 vagrant vagrant DC03
reboot_win 192.168.77.22 "child\\analyst_t1" "T13r_An@lyst!" MBR01
reboot_win 192.168.77.23 "range\\svc_naa" "N@A_s3rv1c3!" MBR02
reboot_win 192.168.77.62 "child\\analyst_t1" "T13r_An@lyst!" WS01
echo "=== LINUX01 reboot ==="
sshpass -p 'vagrant' ssh -o StrictHostKeyChecking=no -o BatchMode=yes vagrant@192.168.77.40 "echo vagrant | sudo -S reboot" 2>&1 | head -3 || echo "linux01 reboot attempted via fallback"
echo "=== DONE-SCHEDULED ==="
