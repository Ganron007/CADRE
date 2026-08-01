# Full AD attribute dump (no restriction) + LocationServices send-failure context — CONFIG, vagrant
$ErrorActionPreference = 'Continue'
$user = 'RANGE\svc_naa'; $pass = 'N@A_s3rv1c3!'

Write-Output '=== ALL attributes: SMS-MP-CAD object ==='
try {
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/CN=SMS-MP-CAD-MBR02.RANGE.LOCAL,CN=System Management,CN=System,DC=range,DC=local", $user, $pass)
  $root.RefreshCache()
  $props = $root.Properties
  foreach ($name in $props.PropertyNames) {
    $v = $props[$name]
    if (($v | Measure-Object).Count -gt 0) {
      $s = [string]$v[0]
      $disp = if ($s.Length -gt 60) { $s.Substring(0,60) + "..." } else { $s }
      Write-Output ("  " + $name + " = " + $disp)
    }
  }
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== ALL attributes: SMS-Site-CAD object ==='
try {
  $root = New-Object System.DirectoryServices.DirectoryEntry("LDAP://dc03.range.local/CN=SMS-Site-CAD,CN=System Management,CN=System,DC=range,DC=local", $user, $pass)
  $root.RefreshCache()
  $props = $root.Properties
  foreach ($name in $props.PropertyNames) {
    $v = $props[$name]
    if (($v | Measure-Object).Count -gt 0) {
      $s = [string]$v[0]
      $disp = if ($s.Length -gt 60) { $s.Substring(0,60) + "..." } else { $s }
      Write-Output ("  " + $name + " = " + $disp)
    }
  }
} catch { Write-Output ("  ERROR: " + $_.Exception.Message) }

Write-Output '=== LocationServices.log: context around Failed to send ==='
$ls = 'C:\Program Files\SMS_CCM\Logs\LocationServices.log'
if (Test-Path $ls) {
  $lines = Get-Content $ls
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'Failed to send|Failed to check|Unable|ERROR|error|0x[0-9A-Fa-f]{8}') {
      $start = [Math]::Max(0, $i - 2)
      $end = [Math]::Min($lines.Count - 1, $i + 3)
      Write-Output ("  --- block @" + $i)
      for ($j = $start; $j -le $end; $j++) {
        if ($lines[$j] -match '<LOG\[(.*?)\]LOG\]!><time="([^"]+)"') { Write-Output ("    [" + $matches[2] + "] " + $matches[1]) } else { Write-Output ("    " + $lines[$j]) }
      }
      $i = $end
    }
  }
} else { Write-Output '  (no LocationServices.log)' }
Write-Output 'FULLAD_DONE'
