#!/bin/bash
# Check Defender state on DCs + member servers via nxc winrm with base64 command
CMD='$st=Get-Service WinDefend -ErrorAction SilentlyContinue; $pol=Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -ErrorAction SilentlyContinue; "WINDEFEND=" + $st.Status + "|startmode=" + (Get-CimInstance Win32_Service -Filter "Name=''WinDefend''" -ErrorAction SilentlyContinue).StartMode; "POLICY=" + $pol.DisableAntiSpyware'
B64=$(printf '%s' "$CMD" | iconv -f UTF-8 -t UTF-16LE | base64 -w0)
for ip in 192.168.77.10 192.168.77.11 192.168.77.12 192.168.77.23; do
  echo "=== $ip ==="
  /tmp/nxc-venv/bin/nxc winrm "$ip" -u vagrant -p vagrant -X "powershell -NoProfile -EncodedCommand $B64" 2>&1 | grep -E 'WINRM|WINDEFEND|POLICY|\[-\]' | head -6
done
