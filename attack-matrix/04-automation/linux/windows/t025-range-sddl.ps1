$ErrorActionPreference = 'Stop'
$user = 'range.local\svc_naa'
$pass = 'N@A_s3rv1c3!'
$asd = 'LDAP://192.168.77.12/CN=AdminSDHolder,CN=System,DC=range,DC=local'

$de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$sd = $de.ObjectSecurity
Write-Output ('RANGE_SDDL ' + $sd.GetSecurityDescriptorSddlForm('All'))
Write-Output ('RANGE_OWNER ' + $sd.GetOwner([System.Security.Principal.SecurityIdentifier]).Value)
Write-Output ('RANGE_GROUP ' + $sd.GetGroup([System.Security.Principal.SecurityIdentifier]).Value)
Write-Output ('RANGE_PROTECTED ' + $sd.AreAccessRulesProtected)
Write-Output ('RANGE_PROTECTED_FOR_CHILDREN ' + $sd.AreAuditRulesProtected)
