# Locate ccmsetup.exe on mbr02 — run from ws01 as svc_naa
$ErrorActionPreference = 'Continue'
$co = New-Object System.Management.ConnectionOptions
$co.Username = 'RANGE\svc_naa'
$co.Password = 'N@A_s3rv1c3!'
$co.Authentication = [System.Management.AuthenticationLevel]::PacketPrivacy
$scope = New-Object System.Management.ManagementScope('\\mbr02.range.local\root\cimv2', $co)
$scope.Connect()
Write-Output '=== C:\Windows\CCMSetup files ==='
try {
  $q = New-Object System.Management.ObjectQuery("SELECT FileName,FileSize FROM CIM_DataFile WHERE Path='C:\\Windows\\CCMSetup\\'")
  $s = New-Object System.Management.ManagementObjectSearcher($scope, $q)
  foreach ($o in $s.Get()) { Write-Output ('  ' + $o['FileName'] + ' (' + $o['FileSize'] + ')') }
} catch { Write-Output ('ERR: ' + $_.Exception.Message) }
Write-Output '=== Client source on site server ==='
foreach ($p in @('C:\Program Files\Microsoft Configuration Manager\Client\','C:\Program Files\Microsoft Configuration Manager\Client\ccmsetup.exe','C:\Program Files\SMS_CCM\')) {
  $esc = $p.Replace('\','\\')
  try {
    $q = New-Object System.Management.ObjectQuery("SELECT FileName FROM CIM_DataFile WHERE Path='$esc'")
    $s = New-Object System.Management.ManagementObjectSearcher($scope, $q)
    $n = 0
    foreach ($o in $s.Get()) { if ($n -lt 8) { Write-Output ('  ' + $p + ' -> ' + $o['FileName']) }; $n++ }
    if ($n -eq 0) { Write-Output ('  ' + $p + ' -> (empty)') }
  } catch { Write-Output ('  ' + $p + ' -> ERR: ' + $_.Exception.Message) }
}
Write-Output 'LOCATE_DONE'
