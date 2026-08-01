#!/bin/bash
# Comprehensive Defender state check across CADRE Windows VMs
# DCs: vagrant/vagrant ; mbr01/ws01: child\analyst_t1 ; mbr02: range\svc_naa
NXC=/tmp/nxc-venv/bin/nxc

CMD='
$ErrorActionPreference = "SilentlyContinue";
$st = Get-Service WinDefend;
$pol = (Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware).DisableAntiSpyware;
$sm = (Get-CimInstance Win32_Service -Filter "Name=''WinDefend''").StartMode;
$mps = Get-MpComputerStatus;
"WINDEFEND=" + $st.Status + "|startmode=" + $sm + "|DisableAntiSpyware=" + $pol;
"MPSTAT|RTP=" + $mps.RealTimeProtectionEnabled + "|TP=" + $mps.IsTamperProtected + "|AV=" + $mps.AntivirusEnabled;
'
B64=$(printf '%s' "$CMD" | iconv -f UTF-8 -t UTF-16LE | base64 -w0)

run_check() {
  local ip=$1; local u=$2; local p=$3; local name=$4
  echo "=== $name ($ip) ==="
  $NXC winrm "$ip" -u "$u" -p "$p" -X "powershell -NoProfile -EncodedCommand $B64" 2>&1 | grep -E 'WINDEFEND=|MPSTAT|\[+\]|\[-\]' | grep -vE 'Missing closing|CategoryInfo|FullyQualifiedErrorId|ParserError|\+ ' | head -8
}

run_check 192.168.77.10 vagrant vagrant DC01
run_check 192.168.77.11 vagrant vagrant DC02
run_check 192.168.77.12 vagrant vagrant DC03
run_check 192.168.77.22 "child\\analyst_t1" "T13r_An@lyst!" MBR01
run_check 192.168.77.23 "range\\svc_naa" "N@A_s3rv1c3!" MBR02
run_check 192.168.77.62 "child\\analyst_t1" "T13r_An@lyst!" WS01
echo "=== DONE ==="
