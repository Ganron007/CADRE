#!/usr/bin/env bash
# T042 — MSSQL CLR probe from ws01 → mbr02 (range.local SQL)
set -euo pipefail
source "$(dirname "$0")/../lib/campaign-a-common.sh"

CASE_ID="CADRE-T042-CLR-${CASE_DATE:-$(date -u +%Y%m%d)}-ws01"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)
MBR02="${MBR02:-192.168.77.23}"
echo "=== T042 | ${CASE_ID} | T0=${T0} ==="

SQL_PS="try { Add-Type -AssemblyName System.Data; \$c=New-Object System.Data.SqlClient.SqlConnection('Server=${MBR02};Database=master;User ID=sa;Password=s@_P@ssw0rd!L@b!;TrustServerCertificate=True'); \$c.Open(); Write-Output SQL_OK; \$cmd=\$c.CreateCommand(); \$cmd.CommandText='SELECT @@version'; Write-Output \$cmd.ExecuteScalar(); \$c.Close() } catch { Write-Output SQL_FAIL:\$_.Exception.Message; exit 1 }"

set +e
ws01_exec_as analyst_t1 'T13r_An@lyst!' "${SQL_PS}"
RC=$?
set -e

cadre_export "${CASE_ID}" T042 "${T0}" 192.168.77.62
echo "T0=${T0} sql_rc=${RC}" | tee "/tmp/${CASE_ID}.t0"
