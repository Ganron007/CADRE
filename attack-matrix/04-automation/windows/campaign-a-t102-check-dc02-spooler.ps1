[CmdletBinding()]
param(
    [string]$DC = "dc02.child.cadre.local",
    [string]$Username = "child.cadre.local\vagrant",
    [string]$Password = "vagrant"
)
$ErrorActionPreference = "Continue"

$cred = New-Object System.Management.Automation.PSCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))

try {
    $session = New-PSSession -ComputerName $DC -Credential $cred -ErrorAction Stop
    Invoke-Command -Session $session -ScriptBlock {
        Write-Output "--- SPOOLER ---"
        $s = Get-Service Spooler -ErrorAction SilentlyContinue
        Write-Output "SPOOLER|$($s.Status)|startmode=$((Get-CimInstance Win32_Service -Filter "Name='Spooler'").StartMode)"

        Write-Output "--- CADRE firewall rules ---"
        Get-NetFirewallRule -DisplayName "CADRE*" -ErrorAction SilentlyContinue | ForEach-Object {
            $ep = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $_ -ErrorAction SilentlyContinue
            $enabled = $_.Enabled
            $action = $_.Action
            $dir = $_.Direction
            Write-Output "FW|$($_.DisplayName)|enabled=$enabled|action=$action|dir=$dir|proto=$($ep.Protocol)|port=$($ep.LocalPort)"
        }

        Write-Output "--- Spooler RPC named pipe reachable? ---"
        $spoolss = Test-Path "\\.\pipe\spoolss"
        Write-Output "PIPE_SPOOLSS|$spoolss"

        Write-Output "--- RPC endpoint mapper listening? ---"
        $netstat = netstat -ano | Select-String ":135\s" | Select-Object -First 3
        $netstat | ForEach-Object { Write-Output "NETSTAT|$_" }
    }
    Remove-PSSession $session
} catch {
    Write-Output "DC02_PS_FAIL: $($_.Exception.Message)"
    exit 1
}
