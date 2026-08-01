# Move HTTP/mbr02.range.local SPN: svc_sccm -> mbr02$ (LocalSystem provider decrypts machine-account tickets)
# Keeps svc_sccm Kerberoastable (WT033) with a realistic decoy SPN (HTTP/sccm.range.local).
$ErrorActionPreference = 'Stop'
$result = @()
try {
  # 1. Decoy SPN on svc_sccm (keeps WT033 cross-forest Kerberoast target)
  $u = Get-ADUser -Identity svc_sccm -Properties ServicePrincipalNames
  if ($u.ServicePrincipalNames -notcontains 'HTTP/sccm.range.local') {
    Set-ADUser -Identity svc_sccm -ServicePrincipalNames @{Add='HTTP/sccm.range.local'}
    $result += 'DECOY_ADDED'
  } else { $result += 'DECOY_PRESENT' }

  # 2. Remove HTTP/mbr02.range.local from svc_sccm (must precede adding to machine — SPN uniqueness)
  $u2 = Get-ADUser -Identity svc_sccm -Properties ServicePrincipalNames
  if ($u2.ServicePrincipalNames -contains 'HTTP/mbr02.range.local') {
    Set-ADUser -Identity svc_sccm -ServicePrincipalNames @{Remove='HTTP/mbr02.range.local'}
    $result += 'SPN_REMOVED_FROM_SVC'
  } else { $result += 'SPN_NOT_ON_SVC' }

  # 3. Add HTTP/mbr02.range.local to mbr02$ (machine account — the LocalSystem REST provider's identity)
  $c = Get-ADComputer -Identity 'mbr02$' -Properties ServicePrincipalNames
  if ($c.ServicePrincipalNames -notcontains 'HTTP/mbr02.range.local') {
    Set-ADComputer -Identity 'mbr02$' -ServicePrincipalNames @{Add='HTTP/mbr02.range.local'}
    $result += 'SPN_ADDED_TO_MACHINE'
  } else { $result += 'SPN_ON_MACHINE' }

  # 4. Verify final state
  $us = (Get-ADUser -Identity svc_sccm -Properties ServicePrincipalNames).ServicePrincipalNames
  $cs = (Get-ADComputer -Identity 'mbr02$' -Properties ServicePrincipalNames).ServicePrincipalNames
  $cd = Get-ADUser -Identity svc_sccm -Properties msDS-AllowedToDelegateTo, TrustedToAuthForDelegation
  $result += ('SVC_SPNS=' + ($us -join ','))
  $result += ('MACHINE_SPNS=' + ($cs -join ','))
  $result += ('CD_ATD=' + (@($cd.'msDS-AllowedToDelegateTo') -join ','))
  $result += ('CD_TRUSTEDTOAUTH=' + $cd.TrustedToAuthForDelegation)
} catch { $result += ('FAILED: ' + $_) }
Write-Output ($result -join ' | ')
Write-Output 'SPN_MOVE_DONE'
