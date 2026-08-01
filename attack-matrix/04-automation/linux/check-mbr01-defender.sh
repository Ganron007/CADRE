#!/bin/bash
NXC=/tmp/nxc-venv/bin/nxc
# CIM-free Defender check for MBR01 (analyst_t1 has no WMI access on this host)
CMD='
$ErrorActionPreference = "Continue";
$svc = Get-Service WinDefend -ErrorAction SilentlyContinue;
$pol = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -ErrorAction SilentlyContinue;
$rtpPol = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name DisableRealtimeMonitoring -ErrorAction SilentlyContinue;
Write-Output ("WINDEFEND=" + $svc.Status + "|DisableAntiSpyware=" + $pol.DisableAntiSpyware + "|DisableRealtimeMonitoring=" + $rtpPol.DisableRealtimeMonitoring);
# Defender status via registry-only WMI path (SEH-safe)
try { $mps = Get-MpComputerStatus -ErrorAction SilentlyContinue; Write-Output ("MPSTAT|RTP=" + $mps.RealTimeProtectionEnabled + "|TP=" + $mps.IsTamperProtected + "|AV=" + $mps.AntivirusEnabled) } catch { Write-Output "MPSTAT_UNAVAILABLE" }
'
B64=$(printf '%s' "$CMD" | iconv -f UTF-8 -t UTF-16LE | base64 -w0)
echo "=== MBR01 (192.168.77.22) ==="
$NXC winrm 192.168.77.22 -u 'child\analyst_t1' -p 'T13r_An@lyst!' -X "powershell -NoProfile -EncodedCommand $B64" 2>&1 | grep -E 'WINDEFEND=|MPSTAT|\[+\]|\[-\]' | head -8
echo "DONE"
