#!/bin/bash
# Encode ps1 as UTF-16LE base64 for -EncodedCommand
B64=$(iconv -f UTF-8 -t UTF-16LE /tmp/apply-ace7.ps1 | base64 -w0)
/tmp/nxc-venv/bin/nxc winrm 192.168.77.10 -u 'cadre\vagrant' -p vagrant -X "powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $B64" 2>&1 | tail -15
