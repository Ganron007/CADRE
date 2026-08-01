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
$searcher.Filter = "(|(objectClass=group)(objectClass=organizationalUnit))"
$searcher.PropertiesToLoad.AddRange(@('name','distinguishedName','objectClass','samaccountname'))
$searcher.PageSize = 1000
$results = $searcher.FindAll()
foreach ($r in $results) {
  $oc = $r.Properties['objectclass'] | Where-Object { $_ -eq 'group' -or $_ -eq 'organizationalUnit' }
  Write-Output "OBJ|$oc|$($r.Properties['name'][0])|$($r.Properties['distinguishedname'][0])"
}
