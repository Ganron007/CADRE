[CmdletBinding()]
param(
    [string]$Server = "192.168.77.23"
)
$ErrorActionPreference = "Stop"
try {
    Add-Type -AssemblyName System.Data
    $c = New-Object System.Data.SqlClient.SqlConnection("Server=$Server;Database=master;User ID=sa;Password=s@_P@ssw0rd!L@b!;TrustServerCertificate=True")
    $c.Open()
    Write-Output "SQL_OK"
    $cmd = $c.CreateCommand()
    $cmd.CommandText = "SELECT @@version"
    Write-Output $cmd.ExecuteScalar()
    $c.Close()
    Write-Output "T042_OK"
} catch {
    Write-Output ("SQL_FAIL:" + $_.Exception.Message)
    exit 1
}
