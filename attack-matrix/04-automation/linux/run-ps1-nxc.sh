#!/bin/bash
# Run a PS1 file on a target via nxc winrm (encoded command path)
NXC=/tmp/nxc-venv/bin/nxc
PS1="$1"
TARGET="$2"
DOMAIN="$3"
USER="$4"
PASS="$5"

B64=$(iconv -f UTF-8 -t UTF-16LE "$PS1" | base64 -w0)
$NXC winrm "$TARGET" -d "$DOMAIN" -u "$USER" -p "$PASS" -X "powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $B64" 2>&1 | tail -20
