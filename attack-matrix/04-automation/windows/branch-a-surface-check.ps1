param(
    [string]$DomainRoot = 'cadre.local',
    [string]$RunAsUser = 'chief_command',
    [string]$RunAsPass = 'C0mm@nd_Ch1ef!',
    [string]$Dc = 'dc01.cadre.local'
)
$ErrorActionPreference = 'Stop'

$cred = New-Object System.Management.Automation.PSCredential("$DomainRoot\$RunAsUser", (ConvertTo-SecureString $RunAsPass -AsPlainText -Force))
$net = $cred.GetNetworkCredential()

# Check gMSA accounts (msDS-GroupManagedServiceAccount / ms-DS-ManagedServiceAccount)
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/DC=cadre,DC=local", $net.UserName, $net.Password)
$searcher.SearchScope = [System.DirectoryServices.SearchScope]'Subtree'
$searcher.PageSize = 500
$searcher.Filter = "(|(objectClass=msDS-GroupManagedServiceAccount)(objectClass=ms-DS-ManagedServiceAccount))"
$searcher.PropertiesToLoad.AddRange(@('name','distinguishedName','sAMAccountName'))
$r = $searcher.FindAll()
Write-Output "GMSA_COUNT $($r.Count)"
foreach ($x in $r) { Write-Output "GMSA|$($x.Properties['samaccountname'][0])|$($x.Properties['distinguishedname'][0])" }

# Check GPOs (Vulnerable-GPO etc)
$searcher2 = New-Object System.DirectoryServices.DirectorySearcher
$searcher2.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/CN=Policies,CN=System,DC=cadre,DC=local", $net.UserName, $net.Password)
$searcher2.SearchScope = [System.DirectoryServices.SearchScope]'OneLevel'
$searcher2.PageSize = 500
$searcher2.Filter = "(objectClass=groupPolicyContainer)"
$searcher2.PropertiesToLoad.AddRange(@('displayName','distinguishedName'))
$r2 = $searcher2.FindAll()
Write-Output "GPO_COUNT $($r2.Count)"
foreach ($x in $r2) { Write-Output "GPO|$($x.Properties['displayname'][0])|$($x.Properties['distinguishedname'][0])" }

# Check SYSVOL Groups.xml (GPP)
$searcher3 = New-Object System.DirectoryServices.DirectorySearcher
$searcher3.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/DC=cadre,DC=local", $net.UserName, $net.Password)
$searcher3.SearchScope = [System.DirectoryServices.SearchScope]'Subtree'
$searcher3.PageSize = 500
$searcher3.Filter = "(objectClass=msDFSR-ContentSet)"
Write-Output "DFSR_CHK"

# Check AdmPwd (LAPS) schema + presence
$searcher4 = New-Object System.DirectoryServices.DirectorySearcher
$searcher4.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Dc/DC=cadre,DC=local", $net.UserName, $net.Password)
$searcher4.SearchScope = [System.DirectoryServices.SearchScope]'Subtree'
$searcher4.PageSize = 500
$searcher4.Filter = "(ms-Mcs-AdmPwd=*)"
$searcher4.PropertiesToLoad.AddRange(@('name','ms-Mcs-AdmPwd'))
$r4 = $searcher4.FindAll()
Write-Output "LAPS_COUNT $($r4.Count)"
foreach ($x in $r4) { Write-Output "LAPS|$($x.Properties['name'][0])|$($x.Properties['ms-mcs-admpwd'][0])" }
