$ErrorActionPreference = 'Stop'
$user = 'cadre.local\chief_command'
$pass = 'C0mm@nd_Ch1ef!'
$asd = 'LDAP://192.168.77.10/CN=AdminSDHolder,CN=System,DC=cadre,DC=local'

$de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$sd = $de.ObjectSecurity
Write-Output ('CADRE_SDDL ' + $sd.GetSecurityDescriptorSddlForm('All'))
Write-Output ('CADRE_OWNER ' + $sd.GetOwner([System.Security.Principal.SecurityIdentifier]).Value)
Write-Output ('CADRE_GROUP ' + $sd.GetGroup([System.Security.Principal.SecurityIdentifier]).Value)
