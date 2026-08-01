[CmdletBinding()]
param(
    [string]$TargetHost = "mbr01.child.cadre.local",
    [string]$Username = "child.cadre.local\analyst_t1",
    [string]$Password = "T13r_An@lyst!"
)
$ErrorActionPreference = "Stop"

$cred = New-Object System.Management.Automation.PSCredential($Username, (ConvertTo-SecureString $Password -AsPlainText -Force))
$session = New-PSSession -ComputerName $TargetHost -Credential $cred

Invoke-Command -Session $session -ScriptBlock {
    param($d)
    Write-Output "--- cadre-tools ---"
    Get-ChildItem $d -ErrorAction SilentlyContinue | Select-Object Name, Length | ForEach-Object { Write-Output "$($_.Name)|$($_.Length)" }
    Write-Output "--- Tools dirs ---"
    Get-ChildItem 'C:\Tools' -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "DIR|$($_.Name)" }
    Write-Output "--- spooler state ---"
    $s = Get-Service Spooler -ErrorAction SilentlyContinue
    Write-Output "SPOOLER|$($s.Status)"
    Write-Output "--- mbr01 delegation flag ---"
    try {
        $p = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' -Name 'DisableLoopbackCheck' -ErrorAction SilentlyContinue
        Write-Output "KERB_LOOPBACK|$($p.DisableLoopbackCheck)"
    } catch { Write-Output "KERB_LOOPBACK|n/a" }
} -ArgumentList 'C:\Windows\Temp\cadre-tools'

Remove-PSSession $session
