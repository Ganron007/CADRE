# WT002 ACE#18 surface check — ws01 native, ADSI, as intern_blue (child.cadre.local)
# Surface (05-ad-attack-surface.yml): intern_blue ExtendedRight (ForceChangePassword)
# on analyst_t2 for User-Force-Change-Password GUID 00299570-246d-11d0-a768-00aa006e0529
$ErrorActionPreference = "Stop"
$user = "child.cadre.local\intern_blue"
$pass = "1nt3rn_Blu3!"
$targetDn = "CN=analyst_t2,OU=Detection,DC=child,DC=cadre,DC=local"
$fcpGUID = "00299570-246d-11d0-a768-00aa006e0529"

try {
    $meIdentity = New-Object System.Security.Principal.NTAccount("child.cadre.local\intern_blue")
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
            if ($r.ObjectType -eq [Guid]$fcpGUID -and ($r.ActiveDirectoryRights -band [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight)) {
                $surface = $true
            }
            if ($r.ActiveDirectoryRights -band [System.DirectoryServices.ActiveDirectoryRights]::GenericAll) {
                $all = $true
            }
        }
    }
    Write-Output "FCP_SURFACE $surface"
    Write-Output "GENERIC_ALL $all"
    Write-Output "TOTAL_RULES $($rules.Count)"
} catch {
    Write-Output "CHECK_FAIL $_"
    exit 1
}
