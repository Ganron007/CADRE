param(
  [string]$Server = '192.168.77.22'
)
Add-Type -AssemblyName System.Data
$cs = "Server=$Server;Database=master;User ID=analyst_t1;Password=T13r_An@lyst!;TrustServerCertificate=True"
$c = New-Object System.Data.SqlClient.SqlConnection($cs)
$c.Open()
$cmd = $c.CreateCommand()
$cmd.CommandText = "EXECUTE AS LOGIN = 'sa'; SELECT SYSTEM_USER AS CurrentLogin;"
$r = $cmd.ExecuteReader()
while ($r.Read()) { Write-Output $r.GetString(0) }
$c.Close()
