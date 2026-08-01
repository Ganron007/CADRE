# Re-dump MP + Site AD objects after publishing — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$user = 'RANGE\svc_naa'; $pass = 'N@A_s3rv1c3!'

foreach ($dn in @(
  'CN=SMS-MP-CAD-MBR02.RANGE.LOCAL,CN=System Management,CN=System,DC=range,DC=local',
  'CN=SMS-Site-CAD,CN=System Management,CN=System,DC=range,DC=local'
)) {
  Write-Output ("=== " + $dn + " ===")
  try {
    $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/$dn", $user, $pass)
    $root.RefreshCache()
    foreach ($name in $root.Properties.PropertyNames) {
      $v = $root.Properties[$name]
      if (($v | Measure-Object).Count -gt 0) {
        $s = [string]$v[0]
        $disp = if ($s.Length -gt 100) { $s.Substring(0,100) + "...(len=" + $s.Length + ")" } else { $s }
        Write-Output ("  " + $name + " = " + $disp)
      }
    }
  } catch { Write-Output ("  ERROR: " + $_.Exception.Message) }
}
Write-Output 'REDUMP_DONE'
