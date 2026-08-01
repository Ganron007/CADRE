# Dump full AD attributes of SCCM objects — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$user = 'RANGE\svc_naa'; $pass = 'N@A_s3rv1c3!'

function Dump-AD([string]$filter, [string]$label) {
  Write-Output ("=== " + $label + " ===")
  try {
    $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/DC=range,DC=local", $user, $pass)
    $s = New-Object System.DirectoryServices.DirectorySearcher($root)
    $s.Filter = $filter
    $s.PropertiesToLoad.AddRange(@('distinguishedname','mSSMSVersion','mSSMSDefaultMP','mSSMSMPAddress','mSSMSCertificate','mSSMSOperationalXML','mSSMSMgmtPoint','mSSMSSiteCode'))
    $res = $s.FindAll()
    Write-Output ("  RESULTS=" + $res.Count)
    foreach ($r in $res) {
      Write-Output ("  --- " + $r.Properties['distinguishedname'])
      foreach ($prop in $r.Properties.PropertyNames) {
        $val = $r.Properties[$prop]
        if ($prop -match 'cert|xml|key') {
          $str = [string]$val[0]
          Write-Output ("    " + $prop + " (len=" + $str.Length + ") = " + $str.Substring(0, [Math]::Min(80, $str.Length)))
        } else {
          Write-Output ("    " + $prop + " = " + $val)
        }
      }
    }
  } catch { Write-Output ("  ERROR: " + $_.Exception.Message) }
}

Dump-AD '(&(objectCategory=mSSMSManagementPoint)(mSSMSSiteCode=CAD))' 'MP object'
Dump-AD '(name=SMS-Site-CAD)' 'SMS-Site-CAD object'
Write-Output 'ADDUMp_DONE'
