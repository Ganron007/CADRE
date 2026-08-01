[CmdletBinding()]
param()
$ErrorActionPreference = 'Continue'

Add-Type -AssemblyName System.DirectoryServices

function Get-DomainSid {
    param([string]$LdapServer, [string]$Username, [string]$Password, [string]$DomainFQDN)
    try {
        $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$LdapServer/DC=$($DomainFQDN.Replace('.',',DC='))", $Username, $Password)
        $root.RefreshCache()
        $sid = $root.Properties["objectSid"][0]
        $sidStr = (New-Object System.Security.Principal.SecurityIdentifier($sid, 0)).Value
        return $sidStr
    } catch {
        return "ERR: $($_.Exception.Message)"
    }
}

Write-Output "--- child.cadre.local SID (dc02) ---"
$childSid = Get-DomainSid -LdapServer 'dc02.child.cadre.local' -Username 'child\analyst_t1' -Password 'T13r_An@lyst!' -DomainFQDN 'child.cadre.local'
Write-Output "CHILD_SID $childSid"

Write-Output "--- cadre.local SID (dc01) ---"
$rootSid = Get-DomainSid -LdapServer 'dc01.cadre.local' -Username 'child\analyst_t1' -Password 'T13r_An@lyst!' -DomainFQDN 'cadre.local'
Write-Output "ROOT_SID $rootSid"

Write-Output "--- root Enterprise Admins SID ---"
if ($rootSid -notlike 'ERR:*') {
    $eaSid = $rootSid + '-519'
    Write-Output "EA_SID $eaSid"
}
