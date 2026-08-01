# WT007 RBCD surface check — ws01 native, ADSI, as analyst_t1 (child.cadre.local)
# Surface (05-ad-attack-surface.yml): analyst_t1 WriteProperty on mbr01$ for
# msDS-AllowedToActOnBehalfOfOtherIdentity (GUID 3f78c3e5-f79a-46bd-a0b8-9d18116ddc79)
$ErrorActionPreference = "Stop"
$user = "child.cadre.local\analyst_t1"
$pass = "T13r_An@lyst!"
$targetDn = "CN=MBR01,CN=Computers,DC=child,DC=cadre,DC=local"
$rbcdGUID = "3f78c3e5-f79a-46bd-a0b8-9d18116ddc79"

try {
    $meIdentity = New-Object System.Security.Principal.NTAccount("child.cadre.local\analyst_t1")
    $me = $meIdentity.Translate([System.Security.Principal.SecurityIdentifier]).Value
    Write-Output "ME_SID $me"

    $de = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc02.child.cadre.local/$targetDn", $user, $pass)
    $de.PsBase.Options.SecurityMasks = [System.DirectoryServices.SecurityMasks]::Dacl
    $sd = $de.PsBase.ObjectSecurity
    $rules = $sd.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])

    $surface = $false
    $all = $false
    foreach ($r in $rules) {
        $idVal = $r.IdentityReference.Value
        $sidVal = $null
        try { $sidVal = $r.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]).Value } catch {}
        if ($idVal -eq $me -or $sidVal -eq $me) {
            $objGuid = ""
            if ($r.ObjectType -ne $null -and $r.ObjectType -ne [Guid]::Empty) { $objGuid = $r.ObjectType.ToString() }
            Write-Output ("ACE rights=" + $r.ActiveDirectoryRights + " obj=" + $objGuid + " id=" + $idVal + " inherit=" + $r.InheritanceFlags)
            if ($r.ObjectType -eq [Guid]$rbcdGUID -and ($r.ActiveDirectoryRights -band [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty)) {
                $surface = $true
            }
            if ($r.ActiveDirectoryRights -band [System.DirectoryServices.ActiveDirectoryRights]::GenericAll) {
                $all = $true
            }
        }
    }
    Write-Output "RBCD_SURFACE $surface"
    Write-Output "GENERIC_ALL $all"
    Write-Output "TOTAL_RULES $($rules.Count)"
} catch {
    Write-Output "CHECK_FAIL $_"
    exit 1
}
