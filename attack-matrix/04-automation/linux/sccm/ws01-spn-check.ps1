# Verify SPN ownership in range.local — analyst_t1 (ws01, ATTACK)
$ErrorActionPreference = 'Continue'
$svcUser = 'RANGE\svc_sccm'
$svcPass = 's3rv1c3_SCCM!'
$sec = ConvertTo-SecureString $svcPass -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($svcUser, $sec)

Write-Output '=== LDAP: who owns HTTP/mbr02.range.local ==='
$path = 'LDAP://dc03.range.local/DC=range,DC=local'
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($path, $svcUser, $svcPass)
$searcher.Filter = '(servicePrincipalName=HTTP/mbr02.range.local)'
$searcher.PropertiesToLoad.AddRange(@('sAMAccountName','servicePrincipalName','objectClass'))
$results = $searcher.FindAll()
if ($results.Count -eq 0) { Write-Output 'NO OWNER FOUND for HTTP/mbr02.range.local' }
foreach ($r in $results) {
  Write-Output ("  sAMAccountName=" + $r.Properties['sAMAccountName'])
  Write-Output ("  objectClass=" + ($r.Properties['objectClass'] -join ','))
  Write-Output ("  SPNs=" + ($r.Properties['servicePrincipalName'] -join ' ; '))
}

Write-Output ''
Write-Output '=== LDAP: who owns HTTP/sccm.range.local (decoy) ==='
$searcher2 = New-Object System.DirectoryServices.DirectorySearcher
$searcher2.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($path, $svcUser, $svcPass)
$searcher2.Filter = '(servicePrincipalName=HTTP/sccm.range.local)'
$searcher2.PropertiesToLoad.AddRange(@('sAMAccountName','servicePrincipalName'))
$res2 = $searcher2.FindAll()
if ($res2.Count -eq 0) { Write-Output 'NO OWNER FOUND for HTTP/sccm.range.local' }
foreach ($r in $res2) {
  Write-Output ("  sAMAccountName=" + $r.Properties['sAMAccountName'])
  Write-Output ("  SPNs=" + ($r.Properties['servicePrincipalName'] -join ' ; '))
}

Write-Output ''
Write-Output '=== LDAP: svc_sccm delegation config (msDS-AllowedToDelegateTo + TrustedToAuth) ==='
$searcher3 = New-Object System.DirectoryServices.DirectorySearcher
$searcher3.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($path, $svcUser, $svcPass)
$searcher3.Filter = '(sAMAccountName=svc_sccm)'
$searcher3.PropertiesToLoad.AddRange(@('sAMAccountName','msDS-AllowedToDelegateTo','userAccountControl'))
$res3 = $searcher3.FindAll()
foreach ($r in $res3) {
  Write-Output ("  sAMAccountName=" + $r.Properties['sAMAccountName'])
  Write-Output ("  AllowedToDelegateTo=" + ($r.Properties['msDS-AllowedToDelegateTo'] -join ' ; '))
  $uac = [int]$r.Properties['userAccountControl'][0]
  Write-Output ("  userAccountControl=" + $uac + " (0x" + $uac.ToString('X') + ")")
}
Write-Output 'SPN_CHECK_DONE'
