Import-Module ActiveDirectory
Set-Location AD:
$acl = Get-Acl "CN=AdminSDHolder,CN=System,DC=cadre,DC=local"
Write-Output ("COUNT " + $acl.Access.Count)
$acl.Access | ForEach-Object {
  Write-Output ("ACE|" + $_.IdentityReference.Value + "|" + $_.ActiveDirectoryRights)
}
