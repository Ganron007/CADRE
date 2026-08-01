param(
    [string]$DomainRoot = 'cadre.local',
    [string]$RunAsUser = 'chief_command',
    [string]$RunAsPass = 'C0mm@nd_Ch1ef!',
    [string]$Dc = 'dc01.cadre.local'
)
$ErrorActionPreference = 'Stop'

$cred = New-Object System.Management.Automation.PSCredential("$DomainRoot\$RunAsUser", (ConvertTo-SecureString $RunAsPass -AsPlainText -Force))
$net = $cred.GetNetworkCredential()

$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/DC=cadre,DC=local", $net.UserName, $net.Password)
$searcher.SearchScope = [System.DirectoryServices.SearchScope]'Subtree'
$searcher.PageSize = 500
$searcher.PropertiesToLoad.AddRange(@('name','cn','distinguishedName','objectClass'))
$searcher.Filter = "(cn=Command-Cadre)"
Write-Output "Filter: $($searcher.Filter)"
$results = $searcher.FindAll()
Write-Output "COUNT $($results.Count)"
foreach ($r in $results) {
  Write-Output "HIT|$($r.Properties['name'][0])|$($r.Properties['cn'][0])|$($r.Properties['distinguishedname'][0])"
}

# Also try objectClass=group with page
$searcher2 = New-Object System.DirectoryServices.DirectorySearcher
$searcher2.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/DC=cadre,DC=local", $net.UserName, $net.Password)
$searcher2.SearchScope = [System.DirectoryServices.SearchScope]'Subtree'
$searcher2.PageSize = 500
$searcher2.Filter = "(objectClass=group)"
$searcher2.PropertiesToLoad.AddRange(@('name','distinguishedName'))
$r2 = $searcher2.FindAll()
$c2 = 0
foreach ($x in $r2) {
  $c2++
  if ($x.Properties['name'][0] -eq 'Command-Cadre') {
    Write-Output "GROUP_HIT|$($x.Properties['distinguishedname'][0])"
  }
}
Write-Output "GROUP_TOTAL $c2"
