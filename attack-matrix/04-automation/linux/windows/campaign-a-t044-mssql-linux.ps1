[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection "Server=192.168.77.22;Database=master;Integrated Security=false;User ID=analyst_t1;Password=T13r_An@lyst!;TrustServerCertificate=True;"
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT name FROM LINUX01.master.sys.databases"
$r = $cmd.ExecuteReader()
while ($r.Read()) { Write-Output ("DB|" + $r[0]) }
$r.Close(); $conn.Close()
Write-Output "T044_OK"
