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
$searcher.Filter = "(|(sAMAccountName=analyst_cloud)(sAMAccountName=chief_command)(sAMAccountName=hunter_dfir)(sAMAccountName=analyst_dfir)(sAMAccountName=eng_agentic))"
$searcher.PropertiesToLoad.AddRange(@('sAMAccountName','distinguishedName'))
$results = $searcher.FindAll()
foreach ($r in $results) {
  Write-Output "OBJ|$($r.Properties['samaccountname'][0])|$($r.Properties['distinguishedname'][0])"
}
